# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class UpdateCasting < Rectify::Command
        def initialize(form, casting)
          @form = form
          @casting = casting
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_casting
          if casting.valid?
            casting.save!
            if casting.file_data_source?
              Decidim::Castings::ImportFileDataSourceJob.perform_later(casting.id)
            end

            broadcast(:ok, casting)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :casting

        def update_casting
          casting.update(
            organization: form.organization,
            author: current_user,
            title: form.title,
            description: form.description,
            amount_of_candidates: form.amount_of_candidates,
            data_source: form.data_source.present? ? form.data_source : Decidim::Casting.data_sources[:file],
            file_first_row_is_a_header: form.file_first_row_is_a_header || true,
            file_columns_separator: form.file_columns_separator || ',',
            status: Decidim::Casting.statuses[:created]
          )
          casting.update(file: form.file) if form.file.present?
        end

      end
    end
  end
end
