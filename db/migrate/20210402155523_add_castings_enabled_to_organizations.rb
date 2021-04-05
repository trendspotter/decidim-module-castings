# frozen_string_literal: true

class AddCastingsEnabledToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :castings_enabled, :boolean
  end
end
