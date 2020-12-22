# frozen_string_literal: true
require 'csv'

module Decidim
  module Castings
    class CreateCastingDataRowsJob < ApplicationJob
      queue_as :default

      def perform(casting_id)
        casting = Decidim::Casting.find(casting_id)

        casting.casting_data_rows.destroy_all
        CSV.foreach(casting.file.path, headers: true, header_converters: :symbol, col_sep: casting.file_columns_separator) do |row|
          casting.casting_data_rows.create!(attrs: row.to_h, raw_data: row.to_s)
        end

      end

    end
  end
end
