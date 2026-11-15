# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:sean_eshbaugh)
    end

    test "should get users index" do
      get admin_users_url

      assert_response :ok
    end

    test "should show a user" do
      user = users(:casie_clark)

      get admin_users_url(user)

      assert_response :ok
    end

    test "should not show a user that does not exist" do
      get admin_user_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "should get a new user" do
      get new_admin_user_url

      assert_response :ok
    end

    test "should get a user to edit" do
      user = users(:casie_clark)

      get edit_admin_user_url(user)

      assert_response :ok
    end

    test "should not get a user that does not exist to edit" do
      get edit_admin_user_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "should create a user" do
      assert_difference("User.count", 1) do
        post admin_users_url, params: { user: { email: "newuser@seaneshbaugh.com", first_name: "New", last_name: "User", password: "test123456", password_confirmation: "test123456" } }
      end

      assert_response :see_other

      assert_redirected_to admin_user_path(User.chronological.last)
    end

    test "should not create an invalid user" do
      assert_no_difference("User.count") do
        post admin_users_url, params: { user: { email: "" } }
      end

      assert_response :unprocessable_entity
    end

    test "should update a user" do
      user = users(:casie_clark)

      patch admin_user_url(user), params: { user: { email: "updateduser@seaneshbaugh.com" } }

      user.reload

      assert_equal("updateduser@seaneshbaugh.com", user.email)

      assert_response :see_other

      assert_redirected_to edit_admin_user_path(user)

      assert_equal(I18n.t("admin.users.update.success"), flash[:success])
    end

    test "should not update a user with invalid data" do
      user = users(:casie_clark)

      patch admin_user_url(user), params: { user: { email: "" } }

      assert_response :unprocessable_entity
    end

    test "should not update a user that does not exist" do
      patch admin_user_url(id: "does-not-exist"), params: { user: { email: "doesnotexist@seaneshbaugh.com" } }

      assert_response :not_found
    end

    test "should destroy a user" do
      user = users(:casie_clark)

      assert_difference("User.count", -1) do
        delete admin_user_url(user)
      end

      assert_response :see_other

      assert_redirected_to admin_users_path
    end

    test "should not destroy a user that does not exist" do
      delete admin_user_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "role sorts and filters return unique users before pagination" do
      admin = users(:sean_eshbaugh)

      admin.add_role(:user)

      26.times do |index|
        copy = users(:casie_clark).dup

        copy.assign_attributes(first_name: "Paging", last_name: "User #{index.to_s.rjust(2, '0')}", email: "paging-#{index}@example.com", slug: "paging-#{index}")
        copy.save!(validate: false)
        copy.add_role(:user)
      end

      [ "asc", "desc" ].each do |direction|
        ids = []

        [ 1, 2 ].each do |page|
          get admin_users_path, params: { q: { s: "role_name #{direction}" }, page: page }

          assert_response :ok

          ids.concat(user_paths)
        end

        assert_equal User.count, ids.length
        assert_equal ids.uniq, ids
        assert_equal admin_user_path(admin), direction == "asc" ? ids.first : ids.last
      end

      get admin_users_path, params: { q: { s: "role_name desc", roles_name_in: %w[admin user] } }

      assert_response :ok

      first_page = user_paths

      assert_equal 25, first_page.length

      get admin_users_path, params: { q: { s: "role_name desc", roles_name_in: %w[admin user] }, page: 2 }

      assert_response :ok

      all = first_page + user_paths

      assert_equal User.count, all.length
      assert_equal all.uniq, all

      get admin_users_path, params: { q: { s: "role_name asc", roles_name_eq: "admin" } }

      assert_response :ok
      assert_equal [ admin_user_path(admin) ], user_paths
    end

    private

    def user_paths
      Nokogiri::HTML(response.body).css("td.user-name a").map { |link| link["href"] }
    end
  end
end
