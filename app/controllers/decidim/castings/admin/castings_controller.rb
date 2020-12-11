# frozen_string_literal: true

module Decidim
  module Castings
    module Admin
      class CastingsController < Castings::Admin::ApplicationController
        helper_method :charts_data_presenter

        before_action :verify_status_for_selection_criteria_actions, only: [:selection_criteria, :edit_selection_criteria, :update_selection_criteria]

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
          if casting.created_status? || casting.importing_status? || casting.importing_error_status?
            render :show_importing
          else
            render :show
          end
        end

        def selection_criteria
          enforce_permission_to :read, :casting
          render :selection_criteria
        end

        def edit_selection_criteria
          enforce_permission_to :update, :casting
          @form = form(CastingSelectionCriteriaForm).from_model(casting)
        end

        def update_selection_criteria
          enforce_permission_to :update, :casting

          c = Decidim::Casting.find(params[:id])
          c.selection_criteria = request.parameters[:selection_criteria]
          # do not using `from_params` because it is converting hash keys format to underscore keys
          @form = form(CastingSelectionCriteriaForm).from_model(c)

          UpdateCastingSelectionCriteria.call(@form, casting) do
            on(:ok) do
              flash[:notice] = I18n.t("castings.selection_criteria.update.success", scope: "decidim.castings.admin")
              redirect_to selection_criteria_casting_path(casting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("castings.selection_criteria.update.error", scope: "decidim.castings.admin")
              render action: "edit_selection_criteria"
            end
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

        def verify_status_for_selection_criteria_actions
          if casting.created_status? || casting.importing_status? || casting.importing_error_status?
            flash[:alert] = t("actions.action_not_available", scope: "decidim.castings.admin")
            redirect_to casting_path(casting)
          end
        end

      end
    end
  end
end
