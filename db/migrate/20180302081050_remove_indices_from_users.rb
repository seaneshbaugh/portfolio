# frozen_string_literal: true

class RemoveIndicesFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :encrypted_password
    remove_index :users, :role
    remove_index :users, :first_name
    remove_index :users, :last_name
    remove_index :users, :reset_password_sent_at
    remove_index :users, :remember_created_at
    remove_index :users, :sign_in_count
    remove_index :users, :current_sign_in_at
    remove_index :users, :last_sign_in_at
    remove_index :users, column: :authentication_token, unique: true
    remove_index :users, :created_at
    remove_index :users, :updated_at
  end
end
