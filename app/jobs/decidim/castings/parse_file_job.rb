# frozen_string_literal: true
require 'csv'

module Decidim
  module Castings
    class ParseFileJob < ApplicationJob
      queue_as :default

      def perform(casting_id)
        casting = Decidim::Casting.find(casting_id)

        return unless Decidim::Casting.statuses.values_at(:created, :import_error).include?(casting.status)

        casting.update_columns(status: Decidim::Casting.statuses[:importing], status_errors: nil)

        begin
          first_row = CSV.foreach(casting.file.path, headers: true, header_converters: :symbol).first
          headers = first_row.headers.dup
          id_header = headers.shift
          _ids = {}
          _stats = {
            total_rows: 0
          }
          _attrs = {}
          headers.each {|h| _attrs[h] = {}}

          CSV.foreach(casting.file.path, headers: true, header_converters: :symbol).with_index(2) do |row, i|
            id = row[id_header]
            errors = []

            errors << "ID in line #{i} is missing" if id.blank?
            errors << "ID in line #{i} is not uniq: #{id}" if _ids[id].present?
            errors << "Line #{i} contains empty values" if _attrs.any?(&:blank?)

            if errors.present?
              set_error(casting, errors)
              return
            end

            _ids[id] = i
            headers.each do |header|
              value = row[header]
              _attrs[header][value] = 0 if _attrs[header][value].blank?
              _attrs[header][value] += 1
            end
          end

          casting.update_columns(
            status: Decidim::Casting.statuses[:imported],
            status_errors: nil,
            import_statistics: {
              total_rows: _ids.keys.count,
              attributes: _attrs
            }
          )
        rescue Exception => e
          set_error(casting, [e.message])
        end
      end

      private

      def set_error(casting, errors)
        casting.update_columns(status: Decidim::Casting.statuses[:import_error], status_errors: {
          message: 'Error parsing file',
          errors: errors
        })
      end

    end
  end
end
