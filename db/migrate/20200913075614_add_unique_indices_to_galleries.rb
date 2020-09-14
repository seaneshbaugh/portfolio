# frozen_string_literal: true

class AddUniqueIndicesToGalleries < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        remove_index :galleries, :name
        remove_index :galleries, :slug

        add_index :galleries, :name, unique: true
        add_index :galleries, :slug, unique: true
      end

      dir.down do
        remove_index :galleries, column: :name, unique: true
        remove_index :galleries, column: :slug, unique: true

        add_index :galleries, :title
        add_index :galleries, :slug
      end
    end
  end
end
