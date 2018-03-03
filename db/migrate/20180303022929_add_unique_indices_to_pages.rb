# frozen_string_literal: true

class AddUniqueIndicesToPages < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        remove_index :pages, :title
        remove_index :pages, :slug

        add_index :pages, :title, unique: true
        add_index :pages, :slug, unique: true
      end

      dir.down do
        remove_index :pages, column: :title, unique: true
        remove_index :pages, column: :slug, unique: true

        add_index :pages, :title
        add_index :pages, :slug
      end
    end
  end
end
