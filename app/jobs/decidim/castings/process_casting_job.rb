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

        begin
          result = casting.casting_results.create!(
            number_of_trials: 0,
            statistics: {}
          )
          last_run_number = casting.max_run_number

          Decidim::Castings::CreateCastingDataRowsJob.perform_now(casting.id)

          MAX_TRIALS.times do |times|
            run_number = last_run_number + 1
            result.update(run_number: run_number)
            Decidim::Castings::CommitteeComposition.new(result).call
            break if result.is_expected_result?
          end
          casting.processed_status!

          casting.casting_data_rows.delete_all

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
