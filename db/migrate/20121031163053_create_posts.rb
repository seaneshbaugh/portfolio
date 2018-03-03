# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.belongs_to :user,       null: false
      t.string :title,          null: false, default: ''
      t.string :slug,           null: false, default: ''
      t.text :body,             null: false, default: ''
      t.text :style,            null: false, default: ''
      t.text :script,           null: false, default: ''
      t.text :meta_description, null: false, default: ''
      t.text :meta_keywords,    null: false, default: ''
      t.boolean :visible,       null: false, default: true
      t.timestamps
    end

    change_table :posts do |t|
      t.index :user_id
      t.index :title, unique: true
      t.index :slug, unique: true
      t.index :visible
      t.index :created_at
      t.index :updated_at
    end
  end
end
