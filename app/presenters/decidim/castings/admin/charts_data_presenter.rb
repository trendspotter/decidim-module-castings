# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class ChartsDataPresenter < Rectify::Presenter
        attribute :casting, Decidim::Casting

        def statistics_charts
          data = []
          casting.data_source_statistics.dig('attributes').each do |k, v|
            data << {
              attribute: k,
              title: k,
              labels: v.keys,
              data: v.values,
            }
          end

          data
        end

      end
    end
  end
end