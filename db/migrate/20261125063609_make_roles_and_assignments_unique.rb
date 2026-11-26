# frozen_string_literal: true

class MakeRolesAndAssignmentsUnique < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users_roles, :user_id, false
    change_column_null :users_roles, :role_id, false
    remove_index :users_roles, [ :user_id, :role_id ]
    add_index :users_roles, [ :user_id, :role_id ], unique: true
    remove_index :users_roles, :user_id

    change_column_null :roles, :name, false
    add_check_constraint :roles, "name ~ '[^[:space:]]'", name: "roles_name_not_blank"
    add_check_constraint :roles, "resource_id IS NULL OR resource_type IS NOT NULL", name: "roles_resource_type_required"
    remove_index :roles, [ :name, :resource_type, :resource_id ]
    add_index :roles, [ :name, :resource_type, :resource_id ], unique: true, nulls_not_distinct: true
  end
end
