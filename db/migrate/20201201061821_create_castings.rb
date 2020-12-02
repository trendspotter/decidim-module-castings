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
      t.integer :amount_of_candidates, null: false, default: 0
      t.string :source, null: false, default: 'file'
      t.string :file, null: false
      t.string :content_type, null: false
      t.string :file_size, null: false
      t.boolean :file_first_row_is_a_header, null: false, default: true
      t.jsonb :file_statistics

      t.timestamps

      t.index [:decidim_organization_id, :status]
      t.index [:decidim_author_id, :decidim_author_type], name: "index_decidim_castings_on_decidim_author"
    end
  end
end
