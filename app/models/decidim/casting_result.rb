# frozen_string_literal: true

module Decidim
  class CastingResult < ApplicationRecord

    belongs_to :casting,
               foreign_key: "decidim_casting_id",
               class_name: "Decidim::Casting"


    def has_results?
      statistics.dig('total_candidates').to_i > 0
    end

  end
end
