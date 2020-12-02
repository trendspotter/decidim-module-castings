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
          # TODO: parse file and compute statistics

          casting.update_columns(status: Decidim::Casting.statuses[:imported], status_errors: nil)
        rescue Exception => e
          casting.update_columns(status: Decidim::Casting.statuses[:import_error], status_errors: {message: e.message})
        end
      end

    end
  end
end
