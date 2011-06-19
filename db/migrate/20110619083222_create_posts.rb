class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.belongs_to :person
      t.text :title, :body, :meta_description, :meta_keywords, :slug
      t.integer :views
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
