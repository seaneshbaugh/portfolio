class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title,    :null => false, :default => ''
      t.string :slug,     :null => false
      t.text :body,       :null => false, :default => ''
      t.text :style,      :null => false, :default => ''
      t.boolean :visible, :null => false, :default => true
      t.timestamps
    end

    change_table :pages do |t|
      t.index :title
      t.index :slug
      t.index :visible
      t.index :created_at
      t.index :updated_at
    end
  end
end
