# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.text :text, null: false, default: ''
      t.text :url, null: false, default: ''
      t.text :description, null: false, default: ''
      t.datetime :published_at, null: false
      t.boolean :visible, null: false, default: true

      t.timestamps
    end

    change_table :links do |t|
      t.index :published_at
    end
  end
end
