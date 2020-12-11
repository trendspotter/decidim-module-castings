# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class UpdateCastingSelectionCriteria < Rectify::Command
        def initialize(form, casting)
          @form = form
          @casting = casting
        end

        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_casting_selection_criteria!
          end

          broadcast(:ok, casting)
        end

        private

        attr_reader :form, :casting

        def update_casting_selection_criteria!
          @casting.selection_criteria.each do |key, value|
            value.each do |k, v|
              @casting.selection_criteria[key][k] = @form.selection_criteria.dig(key, k).to_i
            end
          end

          if casting.save!
            casting.ready_status!
          end
        end
      end
    end
  end
end
