# frozen_string_literal: true

module Decidim
  class Casting < ApplicationRecord
    include Decidim::Authorable

    enum status: {
      created: 'created',
      importing: 'importing',
      import_error: 'import_error',
      imported: 'imported',
      draft: 'draft',
      processing: 'processing',
      processing_error: 'processing_error',
      processed: 'processed'
    }, _suffix: true

    enum source: {
      file: 'file',
      database: 'database'
    }, _suffix: true

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    validates :file, :content_type, presence: true
    validates :file, file_size: {less_than_or_equal_to: ->(_attachment) {Decidim.maximum_attachment_size}}
    mount_uploader :file, Decidim::CastingUploader

    default_scope {order('created_at DESC')}

    # The URL to download the file.
    #
    # Returns String.
    delegate :url, to: :file

    after_create :parse_file, if: ->(c) {c.file_source?}


    # Which kind of file this is.
    #
    # Returns String.
    def file_type
      file.url&.split(".")&.last&.downcase
    end

    private

    def parse_file
      return unless file_source?

      puts '------------------------>>> schedule parse file'
    end

  end
end
