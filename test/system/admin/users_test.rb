require "application_system_test_case"

module Admin
  class UsersTest < ApplicationSystemTestCase
    setup { sign_in users(:sean_eshbaugh) }

    test "a rejected user edit retains names email and roles without changing stored credentials" do
      member = users(:casie_clark)
      member.update!(password: "original-member-password")
      original_attributes = member.attributes.slice(*User.column_names)
      original_roles = member.roles.order(:id).ids

      visit edit_admin_user_path(member)
      fill_in "First Name", with: "Recovered"
      fill_in "Last Name", with: "Member"
      fill_in "Email", with: "recovered.member@example.test"
      uncheck "user_role_ids_#{roles(:user).id}", allow_label_click: true
      check "user_role_ids_#{roles(:admin).id}", allow_label_click: true
      fill_in "user_password", with: "replacement-member-password"
      fill_in "user_password_confirmation", with: "mismatched-member-password"
      click_button "Submit"

      assert_text "Confirm Password doesn't match Password"
      assert_equal original_attributes, member.reload.attributes.slice(*User.column_names)
      assert_equal original_roles, member.roles.order(:id).ids
      assert member.valid_password?("original-member-password")
      assert_not member.valid_password?("replacement-member-password")
      assert_field "user_first_name", with: "Recovered"
      assert_field "user_last_name", with: "Member"
      assert_field "user_email", with: "recovered.member@example.test"
      assert_checked_field "user_role_ids_#{roles(:admin).id}"
      assert_unchecked_field "user_role_ids_#{roles(:user).id}"
      assert_field "user_password", with: ""
      assert_field "user_password_confirmation", with: ""

      fill_in "user_password", with: "replacement-member-password"
      fill_in "user_password_confirmation", with: "replacement-member-password"
      click_button "Submit"
      assert_text "User was successfully updated."
      saved = User.find(member.id)
      assert_current_path edit_admin_user_path(saved)
      assert_equal [ "Recovered", "Member", "recovered.member@example.test" ], saved.attributes.values_at("first_name", "last_name", "email")
      assert_equal [ roles(:admin).id ], saved.roles.ids
      assert saved.valid_password?("replacement-member-password")
      assert_not saved.valid_password?("original-member-password")

      visit edit_admin_user_path(saved)
      assert_field "user_first_name", with: "Recovered"
      assert_field "user_last_name", with: "Member"
      assert_field "user_email", with: saved.email
      assert_checked_field "user_role_ids_#{roles(:admin).id}"
      assert_unchecked_field "user_role_ids_#{roles(:user).id}"
    end

    test "account correction changes credentials atomically and the new password works at login" do
      admin = users(:sean_eshbaugh)
      admin.update!(password: "original-account-password")
      visit edit_admin_account_path
      original_attributes = admin.reload.attributes.slice(*User.column_names)
      original_roles = admin.roles.order(:id).ids

      fill_in "account_first_name", with: "Recovered"
      fill_in "account_last_name", with: "Account"
      fill_in "account_email", with: "recovered.account@example.test"
      fill_in "account_password", with: "replacement-account-password"
      fill_in "account_password_confirmation", with: "mismatched-account-password"
      click_button "Submit"

      assert_text "Confirm Password doesn't match Password"
      assert_equal original_attributes, admin.reload.attributes.slice(*User.column_names)
      assert_equal original_roles, admin.roles.order(:id).ids
      assert admin.valid_password?("original-account-password")
      assert_not admin.valid_password?("replacement-account-password")
      assert_field "account_first_name", with: "Recovered"
      assert_field "account_last_name", with: "Account"
      assert_field "account_email", with: "recovered.account@example.test"
      assert_field "account_password", with: ""
      assert_field "account_password_confirmation", with: ""
      assert_no_selector "input[name='account[role_ids][]']"

      fill_in "account_password", with: "replacement-account-password"
      fill_in "account_password_confirmation", with: "replacement-account-password"
      click_button "Submit"
      assert_text "Your account was successfully updated."
      assert_current_path edit_admin_account_path
      saved = User.find(admin.id)
      assert_equal [ "Recovered", "Account", "recovered.account@example.test" ], saved.attributes.values_at("first_name", "last_name", "email")
      assert_equal original_roles, saved.roles.order(:id).ids

      visit edit_admin_account_path
      assert_field "account_first_name", with: "Recovered"
      assert_field "account_last_name", with: "Account"
      assert_field "account_email", with: saved.email
      assert_field "account_password", with: ""
      assert_field "account_password_confirmation", with: ""

      click_link "Logout"
      assert_current_path root_path
      visit new_user_session_path
      fill_in "Email", with: saved.email
      fill_in "Password", with: "original-account-password"
      find("input[type=submit]").click
      assert_text "Invalid email or password."

      fill_in "Email", with: saved.email
      fill_in "Password", with: "replacement-account-password"
      find("input[type=submit]").click
      assert_current_path root_path
      assert_link "Logout"
      visit edit_admin_account_path
      assert_field "account_email", with: saved.email
      assert_field "account_first_name", with: "Recovered"
    end

    test "create user assign roles edit without changing password and delete" do
      visit new_admin_user_path

      fill_in "First Name", with: "Browser"
      fill_in "Last Name", with: "User"
      fill_in "Email", with: "browser-user@example.test"
      fill_in "Password", with: "browser-user-password", exact: true
      fill_in "Confirm Password", with: "browser-user-password"

      find("label[for='user_role_ids_#{roles(:admin).id}'] span").click

      click_button "Submit"

      saved = User.find_by!(email: "browser-user@example.test")

      assert_current_path admin_user_path(saved)
      assert saved.has_role?(:admin)

      password = saved.encrypted_password

      visit edit_admin_user_path(saved)

      fill_in "Last Name", with: "Updated"

      find("label[for='user_role_ids_#{roles(:admin).id}'] span").click
      find("label[for='user_role_ids_#{roles(:user).id}'] span").click

      click_button "Submit"

      assert_current_path edit_admin_user_path(saved.reload)
      assert_equal "Updated", saved.reload.last_name
      assert_equal password, saved.encrypted_password
      assert saved.has_role?(:user)
      assert_not saved.has_role?(:admin)

      visit admin_user_path(saved)

      accept_confirm { click_link "Delete" }

      assert_current_path admin_users_path
      assert_not User.exists?(saved.id)
    end

    test "account changes preserve a blank password" do
      admin = users(:sean_eshbaugh)
      password = admin.encrypted_password

      visit edit_admin_account_path

      fill_in "First Name", with: "Updated"

      click_button "Submit"

      assert_current_path edit_admin_account_path
      assert_equal "Updated", admin.reload.first_name
      assert_equal password, admin.encrypted_password
    end

    test "one name search matches either first or last name" do
      %w[Sean Eshbaugh].each do |name|
        visit admin_users_path

        fill_in "q_first_name_or_last_name_cont", with: name

        click_button "Search"

        assert_selector "tr.user", count: 1
        assert_link "Sean Eshbaugh"
      end
    end
  end
end
