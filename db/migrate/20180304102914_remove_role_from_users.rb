# frozen_string_literal: true

class RemoveRoleFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :role, :string, null: false, default: ''
  end
end
