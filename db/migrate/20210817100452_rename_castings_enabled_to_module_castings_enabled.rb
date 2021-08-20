# frozen_string_literal: true

class RenameCastingsEnabledToModuleCastingsEnabled < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_organizations, :castings_enabled, :module_castings_enabled
  end
end
