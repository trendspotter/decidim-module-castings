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
      processing: 'processing',
      processing_error: 'processing_error',
      processed: 'processed'
    }, _suffix: true

    enum data_source: {
      file: 'file',
      database: 'database'
    }, _suffix: true

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    validates :file, :file_content_type, presence: true
    validates :file, file_size: {less_than_or_equal_to: ->(_attachment) {Decidim.maximum_attachment_size}}
    mount_uploader :file, Decidim::CastingUploader

    default_scope {order('created_at DESC')}

    # The URL to download the file.
    #
    # Returns String.
    delegate :url, to: :file

    after_create :import_file_data_source, if: ->(c) {c.file_data_source?}


    # Which kind of file this is.
    #
    # Returns String.
    def file_type
      file.url&.split(".")&.last&.downcase
    end

    private

    def import_file_data_source
      return unless file_data_source?

      Decidim::Castings::ImportFileDataSourceJob.set(wait: 5.seconds).perform_later(self.id)
    end

  end
end
