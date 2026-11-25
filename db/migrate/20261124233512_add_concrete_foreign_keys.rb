# frozen_string_literal: true

class AddConcreteForeignKeys < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :posts, :users
    add_foreign_key :gallery_pictures, :galleries
    add_foreign_key :gallery_pictures, :pictures
    add_foreign_key :users_roles, :users
    add_foreign_key :users_roles, :roles
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    add_foreign_key :taggings, :tags
  end
end
