# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class DuplicateCasting < Rectify::Command
        def initialize(form, casting)
          @form = form
          @casting = casting
        end

        def call
          return broadcast(:invalid) if form.invalid?

          @duplicated = duplicate_casting!

          if @duplicated.persisted?
            broadcast(:ok, @duplicated)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :casting

        def duplicate_casting!
          Decidim::Casting.create!(
            organization: form.organization,
            author: current_user,
            title: I18n.t("castings.duplicate.new_name", scope: "decidim.castings.admin", title: form.title),
            description: form.description,
            amount_of_candidates: form.amount_of_candidates,
            data_source: form.data_source.present? ? form.data_source : Decidim::Casting.data_sources[:file],
            file: form.file,
            file_first_row_is_a_header: form.file_first_row_is_a_header || true,
            file_columns_separator: form.file_columns_separator || ',',
            status: Decidim::Casting.statuses[:imported],

            data_source_imported_at: casting.data_source_imported_at,
            data_source_statistics: casting.data_source_statistics,
            attrs_mapping: casting.attrs_mapping,
            selection_criteria: casting.selection_criteria
          )
        end
      end
    end
  end
end
