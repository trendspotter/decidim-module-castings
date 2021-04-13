# frozen_string_literal: true
require 'csv'

module Decidim
  module Castings
    class ProcessCastingJob < ApplicationJob
      queue_as :default

      MAX_TRIALS = 10_000

      def perform(casting_id, force = false)
        casting = Decidim::Casting.find(casting_id)

        return if !force && !casting.processing_scheduled_status?

        casting.update_columns(status: Decidim::Casting.statuses[:processing], status_errors: nil)

        casting.casting_results.destroy_all
        Decidim::Castings::CreateCastingDataRowsJob.perform_now(casting.id)

        MAX_TRIALS.times do |run_number|
          result = casting.casting_results.create!(
            run_number: run_number + 1,
            number_of_trials: 0,
            statistics: {}
          )
          Decidim::Castings::CommitteeComposition.new(result).call
          break if result.is_expected_result?
        end
        casting.processed_status!

      rescue Exception => e
        set_error(casting, [e.message])
      ensure
        casting.casting_data_rows.delete_all
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
