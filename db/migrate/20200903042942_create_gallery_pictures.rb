# frozen_string_literal: true

class CreateGalleryPictures < ActiveRecord::Migration[6.0]
  def change
    create_table :gallery_pictures do |t|
      t.integer :gallery_id, null: false
      t.integer :picture_id, null: false
      t.integer :order,      default: 0, null: false
      t.boolean :visible,    default: true, null: false
      t.boolean :featured,   default: false, null: false

      t.timestamps
    end

    change_table :gallery_pictures do |t|
      t.index :gallery_id
      t.index :picture_id
    end
  end
end
