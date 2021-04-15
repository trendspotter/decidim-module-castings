# frozen_string_literal: true

module Decidim
  class CastingUploader < ApplicationUploader
    include CarrierWave::MiniMagick

    process :set_content_type_and_size_in_model

    protected

    def extension_whitelist
      %w(csv xlsx)
    end

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_whitelist
      [
        %r{text\/csv},
        %r{text\/x-csv},
        %r{text\/comma-separated-values},
        %r{text\/x-comma-separated-values},
        %r{application\/csv},
        %r{application\/x-csv},
        %r{application\/vnd.ms-excel},
        %r{application\/vnd.openxmlformats-officedocument.spreadsheetml},
      ]
    end

    # Copies the content type and file size to the model where this is mounted.
    #
    # Returns nothing.
    def set_content_type_and_size_in_model
      model.file_content_type = file.content_type if file.content_type
      model.file_size = file.size
    end

  end
end
