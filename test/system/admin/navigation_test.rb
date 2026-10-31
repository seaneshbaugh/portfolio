require 'application_system_test_case'
require_relative '../../support/system_test_uploads'

module Admin
  class NavigationTest < ApplicationSystemTestCase
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test 'dashboard navigation reaches each management list' do
      visit admin_root_path

      %w[Posts Pages Pictures Galleries Links Users].each do |resource|
        within '.main-header-nav' do
          click_link resource
        end

        assert_current_path "/admin/#{resource.downcase}"
        assert_selector 'h2', text: resource
      end
    end

    test 'page search sorting and empty results' do
      visit admin_pages_path

      fill_in 'Title', with: 'About'

      click_button 'search'

      assert_selector 'tr.page', count: 1
      assert_link 'About', href: admin_page_path(pages(:about))

      within 'thead' do
        click_link 'Title'
      end

      assert_selector 'tr.page', count: 1

      fill_in 'Title', with: 'No matching page'

      click_button 'search'

      assert_no_selector 'tr.page'
      assert_selector '.no-items'
    end
  end
end
