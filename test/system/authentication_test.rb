require 'application_system_test_case'

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @admin = users(:sean_eshbaugh)
    @admin.update!(password: 'system-test-password')
  end

  test 'login rejects invalid credentials then allows login and logout' do
    visit admin_pages_path

    assert_current_path new_user_session_path

    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'wrong-password'

    find('input[type=submit]').click

    assert_text 'Invalid Email or password.'

    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'system-test-password'

    find('input[type=submit]').click

    visit admin_pages_path

    assert_link 'New Page'

    click_link 'Logout'

    visit admin_pages_path

    assert_current_path new_user_session_path
  end

  test 'non-admin users have account access but cannot manage content' do
    sign_in users(:casie_clark)

    visit admin_account_path
    assert_text 'Casie'

    within '.main-header-nav' do
      assert_no_link 'Pages'
      assert_no_link 'Users'
    end

    visit admin_pages_path

    assert_text 'not allowed to Admin::PagePolicy#index?'
    assert_no_link 'New Page'
  end

  test 'password reset email leads to a working new password' do
    ActionMailer::Base.deliveries.clear

    visit new_user_password_path

    fill_in 'Email', with: @admin.email

    find('input[type=submit]').click

    assert_eventually { ActionMailer::Base.deliveries.any? }

    mail = ActionMailer::Base.deliveries.last

    assert_equal [@admin.email], mail.to

    url = Nokogiri::HTML(mail.body.decoded).at_css('a')['href']
    # Mail links use the configured public host; keep the browser on Capybara.
    uri = URI.parse(url)

    visit "#{uri.path}?#{uri.query}"

    fill_in 'user_password', with: 'replacement-password'
    fill_in 'user_password_confirmation', with: 'replacement-password'

    find('input[type=submit]').click

    assert_eventually { @admin.reload.valid_password?('replacement-password') }

    click_link 'Logout'

    visit new_user_session_path

    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'replacement-password'

    find('input[type=submit]').click

    visit admin_pages_path

    assert_link 'New Page'
  end
end
