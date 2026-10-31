require 'application_system_test_case'
require_relative '../../support/system_test_uploads'

module Admin
  class PicturesTest < ApplicationSystemTestCase
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test 'chooser uploads multiple images and keeps them after reload' do
      visit admin_pictures_path

      attach_file [fixture_file_path('conney-the-corgi.jpg'), fixture_file_path('cowboy-the-cowdog.jpg')], make_visible: true

      assert_selector 'tr.picture', count: 4
      assert_no_text 'Uploading…'

      saved = Picture.where(title: %w[conney-the-corgi cowboy-the-cowdog]).to_a

      assert_equal 2, saved.length
      assert saved.all? { |picture| picture.image.attached? }

      refresh

      saved.each { |picture| assert_link picture.title }
    end

    test 'drop uploads a real image through Active Storage' do
      visit admin_pictures_path

      # Firefox/Selenium cannot drag a host file into the remote browser. Build a
      # real File and DataTransfer, then dispatch the browser's drop event. The
      # upload requests, storage and Redux update all run normally.
      bytes = Base64.strict_encode64(File.binread(fixture_file_path('conney-the-corgi.jpg')))

      find('.image-uploader').execute_script(<<~JS, bytes)
        const bytes = Uint8Array.from(atob(arguments[0]), c => c.charCodeAt(0));
        const transfer = new DataTransfer();
        transfer.items.add(new File([bytes], 'dropped-image.jpg', { type: 'image/jpeg' }));
        this.dispatchEvent(new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer: transfer }));
      JS

      assert_link 'dropped-image'
      assert Picture.find_by!(title: 'dropped-image').image.attached?

      refresh

      assert_link 'dropped-image'
    end

    test 'non-image selection shows an error without adding a picture' do
      visit admin_pictures_path

      attach_file Rails.root.join('test/fixtures/pages.yml'), make_visible: true

      assert_selector '[role=alert]', text: 'Please choose an image.'
      assert_selector 'tr.picture', count: 2
      assert_equal 2, Picture.count
    end

    test 'picture metadata can be edited and the picture deleted' do
      picture = pictures(:conney)

      visit edit_admin_picture_path(picture)

      fill_in 'Title', with: 'Updated photograph'
      fill_in 'Alt Text', with: 'A corgi outdoors'

      click_button 'Submit'

      assert_current_path edit_admin_picture_path(picture.reload)
      assert_equal 'A corgi outdoors', picture.reload.alt_text

      visit admin_picture_path(picture)

      accept_confirm { click_link 'Delete' }

      assert_current_path admin_pictures_path
      assert_not Picture.exists?(picture.id)
    end

    test 'a rejected picture save displays the server message without updating the list' do
      visit admin_pictures_path

      # Simulate a validation response at the fetch boundary; the preceding
      # Active Storage direct upload remains real.
      page.execute_script(<<~JS)
        const originalFetch = window.fetch.bind(window);
        window.fetch = (url, options) => url === '/admin/pictures' && options?.method === 'POST'
          ? Promise.resolve(new Response(JSON.stringify({errors: [{title: 'Picture was rejected'}]}), {
              status: 422, headers: {'Content-Type': 'application/json'}
            }))
          : originalFetch(url, options);
      JS

      attach_file fixture_file_path('conney-the-corgi.jpg'), make_visible: true

      assert_selector '[role=alert]', text: 'Picture was rejected'
      assert_no_text 'Uploading…'
      assert_selector 'tr.picture', count: 2
      assert_equal 2, Picture.count
    end
  end
end
