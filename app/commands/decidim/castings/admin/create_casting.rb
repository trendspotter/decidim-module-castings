# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class CreateCasting < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            @casting = create_casting!
          end

          if @casting.persisted?
            broadcast(:ok, @casting)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_casting!
          Decidim::Casting.create!(
            organization: form.organization,
            author: current_user,
            title: form.title,
            description: form.description,
            amount_of_candidates: form.amount_of_candidates,
            data_source: form.data_source.present? ? form.data_source : Decidim::Casting.data_sources[:file],
            file: form.file,
            file_first_row_is_a_header: form.file_first_row_is_a_header || true,
            file_columns_separator: form.file_columns_separator || ',',
            status: Decidim::Casting.statuses[:created]
          )
        end
      end
    end
  end
end
