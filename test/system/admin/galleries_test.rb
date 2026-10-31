require 'application_system_test_case'
require_relative '../../support/editor_system_test_helpers'
require_relative '../../support/system_test_uploads'

module Admin
  class GalleriesTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test 'create a gallery with selected pictures and remove a saved membership' do
      visit new_admin_gallery_path

      fill_in 'Name', with: 'Browser gallery'
      fill_in_ace 'gallery_description', with: '<p>Gallery description.</p>'

      select_picture pictures(:conney), button: 'Add Picture'
      select_picture pictures(:cowboy), button: 'Add Picture'

      within all('.gallery-picture').first do
        check 'Featured', allow_label_click: true
      end

      click_button 'Submit'

      gallery = Gallery.find_by!(name: 'Browser gallery')

      assert_current_path admin_gallery_path(gallery)
      assert_equal [pictures(:conney).id, pictures(:cowboy).id], gallery.gallery_pictures.by_order.pluck(:picture_id)
      assert_equal pictures(:conney), gallery.featured_picture

      visit edit_admin_gallery_path(gallery)

      within all('.gallery-picture').first do
        click_button 'delete_forever'
      end

      assert_selector '.gallery-picture', count: 1

      click_button 'Submit'

      assert_current_path edit_admin_gallery_path(gallery)
      assert_equal [pictures(:cowboy).id], gallery.gallery_pictures.reload.pluck(:picture_id)

      visit admin_gallery_path(gallery)

      accept_confirm { click_link 'Delete' }

      assert_current_path admin_galleries_path
      assert_not Gallery.exists?(gallery.id)
    end

    test 'drag reordering and featured and visible flags persist after reopening' do
      gallery = galleries(:salt_plains)

      visit edit_admin_gallery_path(gallery)

      rows = all('.gallery-picture', count: 2)

      rows.first.execute_script('this.scrollIntoView({block: "start"})')
      page.driver.browser.action.move_to(rows.first.native).click_and_hold.pause(duration: 0.2)
        .move_by(0, 10).pause(duration: 0.2).move_to(rows.last.native, y: 30).pause(duration: 0.2).release.perform
      # Gecko's WebDriver gesture moves the row but omits dragend after React
      # relocates the source node. Complete that DOM event without changing state.
      rows.first.execute_script("this.dispatchEvent(new DragEvent('dragend', {bubbles: true}))")

      assert_no_selector '.gallery-picture.dragging', visible: :all
      assert_selector "input[name='gallery[gallery_pictures_attributes][0][picture_id]'][value='#{pictures(:cowboy).id}']", visible: :all

      within gallery_row(pictures(:cowboy)) do
        check 'Featured', allow_label_click: true
      end

      within gallery_row(pictures(:conney)) do
        find('label', text: 'Visible', exact_text: true).find('span').click

        assert_unchecked_field 'Visible', visible: :all
      end

      click_button 'Submit'

      assert_current_path edit_admin_gallery_path(gallery)

      memberships = gallery.gallery_pictures.reload.by_order.to_a

      assert_equal [pictures(:cowboy).id, pictures(:conney).id], memberships.map(&:picture_id)
      assert memberships.first.featured
      assert_not memberships.last.visible
      assert_not memberships.last.featured

      visit edit_admin_gallery_path(gallery)

      within gallery_row(pictures(:cowboy)) do
        assert_checked_field 'Featured', visible: :all
      end

      within gallery_row(pictures(:conney)) do
        assert_unchecked_field 'Visible', visible: :all
      end
    end

    test 'invalid gallery retains selections and unsaved selections can be removed' do
      visit new_admin_gallery_path

      select_picture pictures(:conney), button: 'Add Picture'

      click_button 'Submit'

      assert_text "Name can't be blank"
      assert_selector '.gallery-picture', count: 1

      within '.gallery-picture' do
        click_button 'delete_forever'
      end

      assert_no_selector '.gallery-picture'

      fill_in 'Name', with: 'Corrected empty gallery'

      click_button 'Submit'

      gallery = Gallery.find_by!(name: 'Corrected empty gallery')

      assert_current_path admin_gallery_path(gallery)
      assert_empty gallery.gallery_pictures
    end

    private

    def gallery_row(picture)
      find(".gallery-picture input[name$='[picture_id]'][value='#{picture.id}']", visible: :all).find(:xpath, '..')
    end
  end
end
