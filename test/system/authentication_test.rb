require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @admin = users(:sean_eshbaugh)
    @admin.update!(password: "system-test-password")
  end

  test "login rejects invalid credentials then allows login and logout" do
    visit admin_pages_path

    assert_current_path new_user_session_path

    fill_in "Email", with: @admin.email
    fill_in "Password", with: "wrong-password"

    find("input[type=submit]").click

    assert_text "Invalid email or password."

    fill_in "Email", with: @admin.email
    fill_in "Password", with: "system-test-password"

    find("input[type=submit]").click

    assert_current_path admin_pages_path

    assert_link "New Page"

    click_link "Logout"

    assert_current_path root_path
    assert_no_link "Logout"

    visit admin_pages_path

    assert_current_path new_user_session_path
  end

  test "non-admin users have account access but cannot manage content" do
    sign_in users(:casie_clark)

    visit admin_account_path
    assert_text "Casie"

    within ".main-header-nav" do
      assert_no_link "Pages"
      assert_no_link "Users"
    end

    visit admin_pages_path

    assert_text "not allowed to Admin::PagePolicy#index?"
    assert_no_link "New Page"
  end

  test "non-admin direct links deny user management and post edits but allow account recovery" do
    member = users(:casie_clark)

    member.update!(password: "member-access-password")

    sign_in member

    visit admin_account_path

    assert_text "Casie"

    visit admin_users_path

    assert_text "not allowed to Admin::UserPolicy#index?"
    assert_no_link "New User"

    visit edit_admin_post_path(posts(:first_post))

    assert_text "not allowed to Admin::PostPolicy#edit?"
    assert_no_selector "form.edit_post"

    visit edit_admin_account_path

    assert_field "First Name", with: member.first_name

    fill_in "First Name", with: "Updated member"

    click_button "Submit"

    assert_current_path edit_admin_account_path
    assert_equal "Updated member", member.reload.first_name
    assert_not member.has_role?(:admin)

    click_link "Logout"

    assert_current_path root_path

    visit admin_users_path

    assert_current_path new_user_session_path
  end

  test "an invalid reset link leaves the password unchanged and provides a route to request a new one" do
    original_password = @admin.encrypted_password

    visit edit_user_password_path(reset_password_token: "invalid-reset-link")

    fill_in "user_password", with: "invalid-link-password"
    fill_in "user_password_confirmation", with: "invalid-link-password"

    click_button "Update password"

    assert_text "Reset Password Token is invalid"
    assert_equal original_password, @admin.reload.encrypted_password
    assert @admin.valid_password?("system-test-password")
    assert_not @admin.valid_password?("invalid-link-password")
    assert_no_link "Logout"

    click_link "Login", exact: true

    assert_current_path new_user_session_path

    click_link "Forgot your password?", exact: true

    assert_current_path new_user_password_path
    assert_field "Email"
    assert_button "Send reset instructions"
  end

  test "an expired emailed reset link leaves the password unchanged and a fresh link works" do
    expired_link = request_password_reset_link
    original_password = @admin.reload.encrypted_password

    @admin.update_column(:reset_password_sent_at, (User.reset_password_within + 1.minute).ago)

    visit expired_link

    fill_in "user_password", with: "expired-link-password"
    fill_in "user_password_confirmation", with: "expired-link-password"

    click_button "Update password"

    assert_text "Reset Password Token has expired, please request a new one"
    assert_equal original_password, @admin.reload.encrypted_password
    assert @admin.valid_password?("system-test-password")
    assert_not @admin.valid_password?("expired-link-password")
    assert_no_link "Logout"

    click_link "Login", exact: true

    assert_current_path new_user_session_path

    click_link "Forgot your password?", exact: true

    assert_current_path new_user_password_path

    visit request_password_reset_link
    fill_in "user_password", with: "fresh-link-password"
    fill_in "user_password_confirmation", with: "fresh-link-password"

    click_button "Update password"

    assert_current_path root_path
    assert_link "Logout"
    assert @admin.reload.valid_password?("fresh-link-password")
    assert_not @admin.valid_password?("system-test-password")
  end

  test "mismatched reset passwords can be corrected in the same form without requesting another link" do
    visit request_password_reset_link

    original_password = @admin.reload.encrypted_password

    fill_in "user_password", with: "corrected-reset-password"
    fill_in "user_password_confirmation", with: "mismatched-reset-password"

    click_button "Update password"

    assert_text "Confirm Password doesn't match Password"
    assert_equal original_password, @admin.reload.encrypted_password
    assert @admin.valid_password?("system-test-password")
    assert_not @admin.valid_password?("corrected-reset-password")
    assert_no_link "Logout"
    assert_field "user_password", with: ""
    assert_field "user_password_confirmation", with: ""

    fill_in "user_password", with: "corrected-reset-password"
    fill_in "user_password_confirmation", with: "corrected-reset-password"

    click_button "Update password"

    assert_current_path root_path
    assert_link "Logout"
    assert @admin.reload.valid_password?("corrected-reset-password")
    assert_not @admin.valid_password?("system-test-password")
  end

  test "password reset email leads to a working new password" do
    visit request_password_reset_link

    fill_in "user_password", with: "replacement-password"
    fill_in "user_password_confirmation", with: "replacement-password"

    find("input[type=submit]").click

    assert_eventually { @admin.reload.valid_password?("replacement-password") }

    click_link "Logout"

    assert_current_path root_path
    assert_no_link "Logout"

    visit new_user_session_path

    fill_in "Email", with: @admin.email
    fill_in "Password", with: "replacement-password"

    find("input[type=submit]").click

    assert_current_path root_path

    visit admin_pages_path

    assert_link "New Page"
  end

  private

  def request_password_reset_link
    ActionMailer::Base.deliveries.clear

    visit new_user_password_path

    fill_in "Email", with: @admin.email

    click_button "Send reset instructions"

    assert_current_path new_user_session_path
    assert_eventually { ActionMailer::Base.deliveries.any? }

    mail = ActionMailer::Base.deliveries.last

    assert_equal [ @admin.email ], mail.to

    # Mail links use the public host; keep the browser on the local test server.
    uri = URI.parse(Nokogiri::HTML(mail.body.decoded).at_css("a")["href"])

    "#{uri.path}?#{uri.query}"
  end
end
