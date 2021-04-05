# frozen_string_literal: true

require "active_support/concern"

module Castings
  module UpdateOrganizationExtend
    extend ActiveSupport::Concern

    included do

      private

      def save_organization
        organization.name = form.name
        organization.host = form.host
        organization.secondary_hosts = form.clean_secondary_hosts
        organization.force_users_to_authenticate_before_access_organization = form.force_users_to_authenticate_before_access_organization
        organization.available_authorizations = form.clean_available_authorizations
        organization.users_registration_mode = form.users_registration_mode
        organization.omniauth_settings = form.encrypted_omniauth_settings
        organization.smtp_settings = form.encrypted_smtp_settings

        organization.castings_enabled = form.castings_enabled

        organization.save!
      end

    end
  end

  ::Decidim::System::UpdateOrganization.send(:include, UpdateOrganizationExtend)
end