# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :pages do |t|
      t.string :title,          null: false, default: ''
      t.string :slug,           null: false, default: ''
      t.text :body,             null: false, default: ''
      t.text :style,            null: false, default: ''
      t.text :script,           null: false, default: ''
      t.text :meta_description, null: false, default: ''
      t.text :meta_keywords,    null: false, default: ''
      t.integer :order,         null: false, default: 0
      t.string :color,          null: false, default: ''
      t.boolean :show_in_menu,  null: false, default: true
      t.boolean :visible,       null: false, default: true
      t.timestamps
    end

    change_table :pages do |t|
      t.index :title
      t.index :slug
      t.index :order
      t.index :show_in_menu
      t.index :visible
    end
  end
end
