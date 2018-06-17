# frozen_string_literal: true

class RemovePaperclipColumnsFromPictures < ActiveRecord::Migration[5.2]
  def change
    remove_index :pictures, :image_file_name
    remove_index :pictures, :image_content_type
    remove_index :pictures, :image_fingerprint

    remove_column :pictures, :image_file_name, :string, null: false
    remove_column :pictures, :image_content_type, :string, null: false
    remove_column :pictures, :image_file_size, :integer, null: false
    remove_column :pictures, :image_fingerprint, :string, null: false
    remove_column :pictures, :image_original_width, :integer, null: false
    remove_column :pictures, :image_original_height, :integer, null: false
    remove_column :pictures, :image_medium_width, :integer, null: false
    remove_column :pictures, :image_medium_height, :integer, null: false
    remove_column :pictures, :image_thumb_width, :integer, null: false
    remove_column :pictures, :image_thumb_height, :integer, null: false
    remove_column :pictures, :image_updated_at, :datetime, null: false
  end
end
