# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          if permission_action.subject == :casting
            if permission_action.scope == :admin && user.admin? && user.organization.castings_enabled?
              allow!
            else
              disallow!
            end
          end

          permission_action
        end
      end
    end
  end
end
