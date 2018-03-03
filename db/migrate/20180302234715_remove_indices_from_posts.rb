# frozen_string_literal: true

class RemoveIndicesFromPosts < ActiveRecord::Migration[5.1]
  def change
    remove_index :posts, :visible
    remove_index :posts, :created_at
    remove_index :posts, :updated_at
  end
end
