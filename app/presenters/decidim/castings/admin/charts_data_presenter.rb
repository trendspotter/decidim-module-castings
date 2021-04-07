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

        def result_statistics(result)
          return [] if result.blank? && result.statistics.blank?

          casting = result.casting
          data = []

          casting.selection_criteria.each do |attr, values|
            sd = values.keys.map {|k| casting.data_source_statistics.dig('attributes', attr, k) || 0}
            rd = values.keys.map {|k| result.statistics.dig('candidates_attributes', attr, k) || 0 }
            sd_total = sd.inject(0, :+)
            rd_total = rd.inject(0, :+)
            sd_percentages = values.keys.map { |k| ((casting.data_source_statistics.dig('attributes', attr, k) * 100).to_f / sd_total).round(2) }
            rd_percentages = values.keys.map { |k| (((result.statistics.dig('candidates_attributes', attr, k) || 0) * 100).to_f / rd_total).round(2) }

            data << {
              attribute: attr,
              title: attr,
              labels: values.keys,
              source_data: sd_percentages,
              result_data: rd_percentages,
            }
          end

          data
        end

        def result_criterion_statistics(result)
          return [] if result.blank? && result.statistics.blank?

          casting = result.casting
          data = []

          casting.selection_criteria.each do |attr, values|
            criterion_data = values.keys.map {|k| values[k] }
            result_data = values.keys.map {|k| result.statistics.dig('candidates_attributes', attr, k) || 0 }

            data << {
              attribute: attr,
              title: attr,
              labels: values.keys,
              criterion_data: criterion_data,
              result_data: result_data,
            }
          end

          data
        end
      end
    end
  end
end