require 'application_system_test_case'
require_relative '../../support/editor_system_test_helpers'

module Admin
  class LinksTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers

    setup { sign_in users(:sean_eshbaugh) }

    test 'create edit and delete a link' do
      visit new_admin_link_path

      fill_in 'Text', with: 'Browser link'
      fill_in 'link_url', with: 'https://example.test/browser'
      fill_in_ace 'link_description', with: '<p>Browser description.</p>'
      fill_in 'link_tag_list', with: 'browser-link'
      fill_in 'link_published_at', with: 'Feb 09, 2021'

      click_button 'Submit'

      saved = Link.find_by!(text: 'Browser link')

      assert_current_path admin_link_path(saved)

      assert_equal '<p>Browser description.</p>', saved.description
      assert_includes saved.tag_list, 'browser-link'

      visit edit_admin_link_path(saved)

      fill_in 'Text', with: 'Updated browser link'

      click_button 'Submit'

      assert_current_path edit_admin_link_path(saved)
      assert_equal 'Updated browser link', saved.reload.text

      visit admin_link_path(saved)

      accept_confirm { click_link 'Delete' }

      assert_current_path admin_links_path
      assert_not Link.exists?(saved.id)
    end
  end
end
