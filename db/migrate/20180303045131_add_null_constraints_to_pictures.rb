# frozen_string_literal: true

class AddNullConstraintsToPictures < ActiveRecord::Migration[5.1]
  def change
    change_column_null :pictures, :image_file_name, false
    change_column_null :pictures, :image_content_type, false
    change_column_null :pictures, :image_file_size, false
    change_column_null :pictures, :image_fingerprint, false
    change_column_null :pictures, :image_updated_at, false
  end
end
