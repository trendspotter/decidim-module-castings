# frozen_string_literal: true

module Decidim
  class Casting < ApplicationRecord
    include Decidim::Authorable

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

    validates :file, :file_content_type, presence: true
    validates :file, file_size: {less_than_or_equal_to: ->(_attachment) {Decidim.maximum_attachment_size}}
    mount_uploader :file, Decidim::CastingUploader

    default_scope {order('created_at DESC')}

    delegate :url, to: :file

    def result
      casting_results.order(:run_number).last
    end

    def file_type
      file.url&.split(".")&.last&.downcase
    end

    def editable?
      created_status? || importing_error_status? || imported_status? || ready_status?
    end

    def can_edit_selection_criteria?
      imported_status? || ready_status?
    end

    def can_start_processing?
      ready_status? || processed_status?
    end

  end
end
