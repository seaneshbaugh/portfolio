# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "creating a user without selected roles assigns only the default member role" do
    user = User.create!(
      first_name: "Default", last_name: "Member", email: "default-member@example.test",
      password: "model-test-password", password_confirmation: "model-test-password"
    )

    assert_equal [ roles(:user).id ], user.reload.roles.ids
  end

  test "creation preserves explicitly selected roles without adding another default role" do
    [ [ roles(:admin) ], [ roles(:admin), roles(:user) ] ].each_with_index do |selected_roles, index|
      user = User.create!(
        first_name: "Selected", last_name: "Roles", email: "selected-roles-#{index}@example.test",
        password: "model-test-password", password_confirmation: "model-test-password",
        roles: selected_roles
      )

      assert_equal selected_roles.map(&:id).sort, user.reload.roles.ids.sort
    end
  end
end
