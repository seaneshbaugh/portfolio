class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.text :title, :body, :style, :meta_description, :meta_keywords, :slug
      t.belongs_to :user
      t.integer :status
      t.boolean :private
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
