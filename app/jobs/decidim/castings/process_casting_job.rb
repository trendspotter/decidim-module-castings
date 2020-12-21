# frozen_string_literal: true
require 'csv'

module Decidim
  module Castings
    class ProcessCastingJob < ApplicationJob
      queue_as :default

      def perform(casting_id, force = false)
        casting = Decidim::Casting.find(casting_id)

        return if !force && !casting.processing_scheduled_status?

        casting.update_columns(status: Decidim::Casting.statuses[:processing], status_errors: nil)

        begin
          run_number = (casting.casting_results.maximum(:run_number) || 0) + 1
          result = casting.casting_results.create!(
            run_number: run_number,
            number_of_trials: 0,
            statistics: {}
          )

          service = Decidim::Castings::CommitteeComposition.new(result)
          service.call

          casting.processed_status!

        rescue Exception => e
          set_error(casting, [e.message])
        end
      end

      private

      def set_error(casting, errors)
        casting.update_columns(status: Decidim::Casting.statuses[:processing_error], status_errors: {
          message: 'Error processing data',
          errors: errors
        })
      end

    end
  end
end
