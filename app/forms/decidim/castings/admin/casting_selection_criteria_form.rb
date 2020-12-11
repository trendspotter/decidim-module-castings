# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class CastingSelectionCriteriaForm < Decidim::Form
        mimic :casting

        attribute :selection_criteria, Hash
        validate :valid_selection_criteria?

        protected

        def valid_selection_criteria?
          amount = casting.amount_of_candidates
          selection_criteria.each do |key, value|
            value.each do |k, v|
              errors.add(:base, I18n.t(:required, scope: i18n_scope), key: "selection_criteria_#{key}_#{k}") if v.blank?
              errors.add(:base, I18n.t(:should_be_positive, scope: i18n_scope), key: "selection_criteria_#{key}_#{k}") if v.present? && v.to_i < 0
            end
            if value.values.sum(&:to_i) != amount
              errors.add(:base, I18n.t(:sum_is_invalid, sum: value.values.sum(&:to_i), scope: i18n_scope), key: "selection_criteria_#{key}")
            end
          end
        end

        private

        def casting
          @casting ||= Decidim::Casting.find(id)
        end

        def i18n_scope
          "activemodel.errors.models.casting.attributes.selection_criteria"
        end
      end
    end
  end
end
