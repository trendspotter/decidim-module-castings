# frozen_string_literal: true

module Decidim
  module Castings
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Castings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :castings do
          member do
            get 'selection_criteria'
            get 'edit_selection_criteria'
            patch 'update_selection_criteria'
            get 'results'
          end
        end
        root to: "castings#index"
      end

      initializer "decidim_castings extends" do
        Dir.glob("#{Decidim::Castings::Engine.root}/lib/extends/castings/**/*.rb").each do |override|
          require_dependency override
        end
      end

      initializer "decidim_castings.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Castings::AdminEngine, at: "/admin", as: "decidim_admin_castings"
        end
      end

      initializer "decidim_castings.admin_assets" do |app|
        app.config.assets.precompile += %w(decidim_castings_manifest.js decidim_castings_manifest.css)
      end

      initializer "decidim_castings.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.castings", scope: "decidim.castings"),
                    decidim_admin_castings.castings_path,
                    icon_name: "people",
                    position: 7.1,
                    active: :inclusive,
                    if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
