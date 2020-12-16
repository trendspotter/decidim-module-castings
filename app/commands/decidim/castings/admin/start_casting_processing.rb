# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class StartCastingProcessing < Rectify::Command
        def initialize(casting)
          @casting = casting
        end

        def call
          return broadcast(:invalid, I18n.t("action_not_available_in_current_status", scope: "decidim.castings.admin.messages")) unless casting.can_start_processing?
          return broadcast(:invalid, I18n.t("no_data_present_to_start_processing", scope: "decidim.castings.admin.messages")) if casting.casting_data_rows.blank?

          Decidim::Castings::ProcessCastingJob.perform_later(casting.id)
          casting.processing_scheduled_status!

          broadcast(:ok, casting)
        end
      end
    end
  end
end
