# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class CastingForm < Decidim::Form
        mimic :casting

        alias organization current_organization

        attribute :title, String
        attribute :description, String
        attribute :amount_of_candidates, Integer
        attribute :source, String

        attribute :file
        attribute :file_first_row_is_a_header, Boolean

        validates :title, presence: true
        validates :amount_of_candidates, numericality: true
        validate :valid_amount_of_candidates?
        validates :file, presence: true, unless: :persisted?

        protected

        def valid_amount_of_candidates?
          errors.add(:amount_of_candidates, :invalid) unless amount_of_candidates.to_i > 0
        end
      end
    end
  end
end
