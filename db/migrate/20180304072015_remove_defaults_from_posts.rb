# frozen_string_literal: true

class RemoveDefaultsFromPosts < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column_default :posts, :slug, nil
      end

      dir.down do
        change_column_default :posts, :slug, ''
      end
    end
  end
end
