# frozen_string_literal: true

class CreateGalleries < ActiveRecord::Migration[6.0]
  def change
    create_table :galleries do |t|
      t.string :name,      default: '', null: false
      t.string :slug,      null: false
      t.text :description, default: '', null: false
      t.integer :order,    default: 0, null: false
      t.boolean :visible,  default: true, null: false

      t.timestamps
    end

    change_table :galleries do |t|
      t.index :name
      t.index :slug
    end
  end
end
