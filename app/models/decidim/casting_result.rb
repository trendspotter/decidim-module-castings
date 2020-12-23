# frozen_string_literal: true

module Decidim
  class CastingResult < ApplicationRecord

    belongs_to :casting,
               foreign_key: "decidim_casting_id",
               class_name: "Decidim::Casting"

    mount_uploader :candidates_file, Decidim::CastingResultFileUploader
    mount_uploader :substitutes_file, Decidim::CastingResultFileUploader

    def has_results?
      total_candidates.to_i > 0
    end

    def total_candidates
      statistics&.dig('total_candidates').to_i
    end

    def total_substitutes
      statistics&.dig('total_substitutes').to_i
    end

  end
end
