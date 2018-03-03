# frozen_string_literal: true

class RemoveDefaultsFromPictures < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column_default :pictures, :image_original_width, nil
        change_column_default :pictures, :image_original_height, nil
        change_column_default :pictures, :image_medium_width, nil
        change_column_default :pictures, :image_medium_height, nil
        change_column_default :pictures, :image_thumb_width, nil
        change_column_default :pictures, :image_thumb_height, nil
      end

      dir.down do
        change_column_default :pictures, :image_original_width, 1
        change_column_default :pictures, :image_original_height, 1
        change_column_default :pictures, :image_medium_width, 1
        change_column_default :pictures, :image_medium_height, 1
        change_column_default :pictures, :image_thumb_width, 1
        change_column_default :pictures, :image_thumb_height, 1
      end
    end
  end
end
