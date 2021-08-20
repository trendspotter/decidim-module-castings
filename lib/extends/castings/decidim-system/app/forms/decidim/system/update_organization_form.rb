# frozen_string_literal: true

require "active_support/concern"

module Castings
  module UpdateOrganizationFormExtend
    extend ActiveSupport::Concern

    included do

      attribute :module_castings_enabled, Virtus::Attribute::Boolean

    end
  end

  ::Decidim::System::UpdateOrganizationForm.send(:include, UpdateOrganizationFormExtend)
end
