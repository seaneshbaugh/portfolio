require 'application_system_test_case'

module Admin
  class UsersTest < ApplicationSystemTestCase
    setup { sign_in users(:sean_eshbaugh) }

    test 'create user assign roles edit without changing password and delete' do
      visit new_admin_user_path

      fill_in 'First Name', with: 'Browser'
      fill_in 'Last Name', with: 'User'
      fill_in 'Email', with: 'browser-user@example.test'
      fill_in 'Password', with: 'browser-user-password', exact: true
      fill_in 'Confirm Password', with: 'browser-user-password'

      find("label[for='user_role_ids_#{roles(:admin).id}'] span").click

      click_button 'Submit'

      saved = User.find_by!(email: 'browser-user@example.test')

      assert_current_path admin_user_path(saved)
      assert saved.has_role?(:admin)

      password = saved.encrypted_password

      visit edit_admin_user_path(saved)

      fill_in 'Last Name', with: 'Updated'

      find("label[for='user_role_ids_#{roles(:admin).id}'] span").click
      find("label[for='user_role_ids_#{roles(:user).id}'] span").click

      click_button 'Submit'

      assert_current_path edit_admin_user_path(saved.reload)
      assert_equal 'Updated', saved.reload.last_name
      assert_equal password, saved.encrypted_password
      assert saved.has_role?(:user)
      assert_not saved.has_role?(:admin)

      visit admin_user_path(saved)

      accept_confirm { click_link 'Delete' }

      assert_current_path admin_users_path
      assert_not User.exists?(saved.id)
    end

    test 'account changes preserve a blank password' do
      admin = users(:sean_eshbaugh)
      password = admin.encrypted_password

      visit edit_admin_account_path

      fill_in 'First Name', with: 'Updated'

      click_button 'Submit'

      assert_current_path edit_admin_account_path
      assert_equal 'Updated', admin.reload.first_name
      assert_equal password, admin.encrypted_password
    end

    test 'one name search matches either first or last name' do
      %w[Sean Eshbaugh].each do |name|
        visit admin_users_path

        fill_in 'q_first_name_or_last_name_cont', with: name

        click_button 'search'

        assert_selector 'tr.user', count: 1
        assert_link 'Sean Eshbaugh'
      end
    end
  end
end
