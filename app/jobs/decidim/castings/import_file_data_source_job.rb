# frozen_string_literal: true
require 'csv'

module Decidim
  module Castings
    class ImportFileDataSourceJob < ApplicationJob
      queue_as :default

      def perform(casting_id, force = false)
        casting = Decidim::Casting.find(casting_id)

        return if !force && !Decidim::Casting.statuses.values_at(:created, :importing_error).include?(casting.status)

        casting.update_columns(status: Decidim::Casting.statuses[:importing], status_errors: nil)

        begin
          first_row = CSV.foreach(casting.file.path, headers: true, header_converters: :symbol).first
          headers = first_row.headers.dup
          id_header = headers.shift
          _ids = {}
          _stats = {}
          _selection_criteria = {}
          headers.each {|h| _stats[h] = {}; _selection_criteria[h] = {}}

          CSV.foreach(casting.file.path, headers: true, header_converters: :symbol).with_index(2) do |row, i|
            id = row[id_header]
            errors = []

            errors << "ID in line #{i} is missing" if id.blank?
            errors << "ID in line #{i} is not uniq: #{id}" if _ids[id].present?
            errors << "Line #{i} contains empty values" if _stats.any?(&:blank?)

            if errors.present?
              set_error(casting, errors)
              return
            end

            _ids[id] = i
            headers.each do |header|
              value = row[header]
              if _stats[header][value].blank?
                _stats[header][value] = 0
                _selection_criteria[header][value] = nil
              end
              _stats[header][value] += 1
            end
          end

          Decidim::Castings::CreateCastingDataRowsJob.perform_now(casting.id)

          casting.update_columns(
            status: Decidim::Casting.statuses[:imported],
            status_errors: nil,
            data_source_imported_at: DateTime.now,
            data_source_statistics: {
              total_rows: _ids.keys.count,
              attributes: _stats
            },
            selection_criteria: _selection_criteria
          )
        rescue Exception => e
          set_error(casting, [e.message])
        end
      end

      private

      def set_error(casting, errors)
        casting.update_columns(status: Decidim::Casting.statuses[:importing_error], status_errors: {
          message: 'Error parsing file',
          errors: errors
        })
      end

    end
  end
end
