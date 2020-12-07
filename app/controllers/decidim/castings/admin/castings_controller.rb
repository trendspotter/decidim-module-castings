# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class CastingsController < Castings::Admin::ApplicationController
        helper_method :charts_data_presenter

        def index
          enforce_permission_to :read, :casting
          castings
        end

        def new
          enforce_permission_to :create, :casting

          @form = form(CastingForm).from_model(Casting.new)
        end

        def create
          enforce_permission_to :create, :casting
          @form = form(CastingForm).from_params(
            params,
            current_organization: current_organization
          )

          CreateCasting.call(@form) do
            on(:ok) do |c|
              flash[:notice] = I18n.t("castings.create.success", scope: "decidim.castings.admin")
              redirect_to casting_path(c)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("castings.create.error", scope: "decidim.castings.admin")
              render action: "new"
            end
          end
        end

        def show
          enforce_permission_to :read, :casting
          if casting.created_status? || casting.importing_status? || casting.import_error_status?
            render :show_importing
          else
            render :show
          end
        end

        private

        def castings
          @castings ||= OrganizationCastings.new(current_organization).query.page(params[:page]).per(20)
        end

        def casting
          @casting ||= Decidim::Casting.find(params[:id])
        end

        def charts_data_presenter
          @charts_data_presenter ||= Decidim::Castings::Admin::ChartsDataPresenter.new(casting: casting)
        end

      end
    end
  end
end
