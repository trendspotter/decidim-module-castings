# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class ChartsDataPresenter < Rectify::Presenter
        attribute :casting, Decidim::Casting

        def data_source_statistics
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

        def result_statistics
          data = []
          # TODO

          data
        end

      end
    end
  end
end