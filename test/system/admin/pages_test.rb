require "application_system_test_case"
require_relative '../../support/editor_system_test_helpers'

module Admin
  class PagesTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    setup do
      @user = users(:sean_eshbaugh)
      sign_in @user
    end

    test "user creates a page" do
      visit admin_pages_path

      click_link "New Page"

      fill_in "Title", with: "Test Page"

      fill_in_ace 'page_body', with: '<p>Testing 1 2 3</p>'
      fill_in_ace 'page_style', with: 'p { color: red; }'
      fill_in_ace 'page_script', with: 'window.pageTest = true;'

      click_button "Submit"

      assert_current_path admin_page_path(Page.last)

      assert_text "Test Page"

      saved = Page.find_by!(title: 'Test Page')

      assert_equal '<p>Testing 1 2 3</p>', saved.body
      assert_equal 'p { color: red; }', saved.style
      assert_equal 'window.pageTest = true;', saved.script

      visit edit_admin_page_path(saved)

      assert_field 'page_body', with: saved.body, visible: :all

      fill_in_ace 'page_body', with: '<p>Updated body.</p>'

      click_button 'Submit'

      assert_current_path edit_admin_page_path(saved)
      assert_equal '<p>Updated body.</p>', saved.reload.body
    end

    test 'invalid input preserves editor contents for correction' do
      visit new_admin_page_path

      fill_in_ace 'page_body', with: '<p>Keep this draft.</p>'

      click_button 'Submit'

      assert_text "Title can't be blank"
      assert_field 'page_body', with: '<p>Keep this draft.</p>', visible: :all

      fill_in 'Title', with: 'Corrected draft'

      click_button 'Submit'

      saved = Page.find_by!(title: 'Corrected draft')

      assert_current_path admin_page_path(saved)
      assert_equal '<p>Keep this draft.</p>', saved.body
    end

    test 'admin deletes a page with confirmation' do
      record = pages(:about)

      visit admin_page_path(record)

      accept_confirm { click_link 'Delete' }

      assert_current_path admin_pages_path
      assert_not Page.exists?(record.id)
    end
  end
end
