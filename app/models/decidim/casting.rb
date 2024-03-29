# frozen_string_literal: true
require 'roo'

module Decidim
  class Casting < ApplicationRecord
    include Decidim::Authorable

    MAX_RUNS = 1000

    enum status: {
      created: 'created',
      importing: 'importing',
      importing_error: 'importing_error',
      imported: 'imported',
      ready: 'ready',
      processing_scheduled: 'processing_scheduled',
      processing: 'processing',
      processing_error: 'processing_error',
      processed: 'processed'
    }, _suffix: true

    enum data_source: {
      file: 'file',
      database: 'database'
    }, _suffix: true

    CSV_FILE_COLUMNS_SEPARATORS = %w(, ;)

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    has_many :casting_data_rows,
             foreign_key: "decidim_casting_id",
             class_name: "Decidim::CastingDataRow",
             dependent: :destroy
    has_many :casting_results,
             foreign_key: "decidim_casting_id",
             class_name: "Decidim::CastingResult",
             dependent: :destroy
    delegate :max_run_number, :best_result, to: :casting_results

    validates :file, :file_content_type, presence: true
    validates :file, file_size: {less_than_or_equal_to: ->(_attachment) {Decidim.maximum_attachment_size}}
    mount_uploader :file, Decidim::CastingUploader

    default_scope {order('created_at DESC')}

    delegate :url, to: :file

    def file_columns_separator
      file_type_excel? ? ',' : self.attributes['file_columns_separator']
    end

    def file_type
      file.url&.split(".")&.last&.downcase
    end

    def file_type_csv?
      file_type == 'csv'
    end

    def file_type_excel?
      file_type == 'xlsx'
    end

    def file_as_csv
      if file_type_excel?
        sheet = Roo::Spreadsheet.open(file._storage.name == 'CarrierWave::Storage::Fog' ? file.url : file.path)
        CSV.new(sheet.to_csv, headers: true, header_converters: :symbol, col_sep: file_columns_separator)
      else
        CSV.new(file.file.read, headers: true, header_converters: :symbol, col_sep: file_columns_separator)
      end
    end

    def editable?
      created_status? || importing_error_status? || imported_status? || ready_status?
    end

    def destroyable?
      created_status? || importing_error_status? || imported_status? || ready_status?
    end

    def can_edit_selection_criteria?
      imported_status? || ready_status?
    end

    def can_start_processing?
      ready_status?
    end

    def clear_data_rows!
      casting_data_rows.delete_all
    end

    def clear_results_except_best_result!
      casting_results.where.not(id: best_result&.id).destroy_all
    end

  end
end
