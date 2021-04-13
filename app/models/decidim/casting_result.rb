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


    def candidates_without_substitutes
      casting.amount_of_candidates - statistics.dig('total_candidates')
    end

    def is_expected_result?
      total_candidates == casting.amount_of_candidates && total_substitutes == casting.amount_of_candidates
    end

    def self.best_result
      where.not(statistics: {}).order(Arel.sql("statistics ->> 'total_candidates' DESC, statistics ->> 'total_substitutes' DESC")).first
    end

    def self.max_run_number
      maximum(:run_number) || 0
    end
  end
end
