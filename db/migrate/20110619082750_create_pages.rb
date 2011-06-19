class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.belongs_to :parent
      t.text :title, :body, :meta_description, :meta_keywords, :slug
      t.boolean :top_menu
      t.integer :display_order
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
