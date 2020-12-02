# frozen_string_literal: true

module Decidim
  module Castings
    class OrganizationCastings < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        q = Decidim::Casting.where(organization: @organization.id)
        q.order(created_at: :desc)
      end

      def count
        query.count(:id)
      end

    end
  end
end
