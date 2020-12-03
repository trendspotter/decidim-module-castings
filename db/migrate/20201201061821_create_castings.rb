# frozen_string_literal: true

class CreateCastings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_castings do |t|
      t.references :decidim_organization, null: false, index: false
      t.bigint :decidim_author_id, null: false
      t.string :decidim_author_type, null: false
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: 'created'
      t.jsonb :status_errors

      # step 1 - data source
      t.string :data_source, null: false, default: 'file'
      t.datetime :data_source_imported_at
      t.string :file, null: false
      t.string :file_content_type, null: false
      t.string :file_size, null: false
      t.boolean :file_first_row_is_a_header, null: false, default: true
      t.jsonb :data_source_statistics

      # step 2 - attributes mapping
      t.jsonb :attributes_mapping

      # step 3 - selection criteria
      t.integer :amount_of_candidates, null: false, default: 0
      t.jsonb :selection_criteria

      # step 4 - run the process
      t.integer :number_of_trials
      t.jsonb :processing_errors

      t.timestamps

      t.index [:decidim_organization_id, :status]
      t.index [:decidim_author_id, :decidim_author_type], name: "index_decidim_castings_on_decidim_author"
    end
  end
end
