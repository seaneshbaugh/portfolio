# frozen_string_literal: true

class RemoveIndicesFromPages < ActiveRecord::Migration[5.1]
  def change
    remove_index :pages, :order
    remove_index :pages, :show_in_menu
    remove_index :pages, :visible
  end
end
