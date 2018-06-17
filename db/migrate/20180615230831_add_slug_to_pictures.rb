class AddSlugToPictures < ActiveRecord::Migration[5.2]
  def change
    add_column :pictures, :slug, :string

    add_index :pictures, :slug
  end
end
