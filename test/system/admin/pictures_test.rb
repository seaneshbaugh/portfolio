require "application_system_test_case"
require_relative "../../support/system_test_uploads"

module Admin
  class PicturesTest < ApplicationSystemTestCase
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test "chooser uploads multiple images and keeps them after reload" do
      visit admin_pictures_path

      attach_file [ fixture_file_path("conney-the-corgi.jpg"), fixture_file_path("cowboy-the-cowdog.jpg") ], make_visible: true

      assert_selector "tr.picture", count: 4
      assert_no_text "Uploading…"

      saved = Picture.where(title: %w[conney-the-corgi cowboy-the-cowdog]).to_a

      assert_equal 2, saved.length
      assert saved.all? { |picture| picture.image.attached? }

      refresh

      saved.each { |picture| assert_link picture.title }
    end

    test "drop uploads a real image through Active Storage" do
      visit admin_pictures_path

      # Firefox/Selenium cannot drag a host file into the remote browser. Build a
      # real File and DataTransfer, then dispatch the browser's drop event. The
      # upload requests, storage and list update all run normally.
      bytes = Base64.strict_encode64(File.binread(fixture_file_path("conney-the-corgi.jpg")))

      find(".image-uploader").execute_script(<<~JS, bytes)
        const bytes = Uint8Array.from(atob(arguments[0]), c => c.charCodeAt(0));
        const transfer = new DataTransfer();
        transfer.items.add(new File([bytes], 'dropped-image.jpg', { type: 'image/jpeg' }));
        this.dispatchEvent(new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer: transfer }));
      JS

      assert_link "dropped-image"
      assert Picture.find_by!(title: "dropped-image").image.attached?

      refresh

      assert_link "dropped-image"
    end

    test "uploaded rows load thumbnails and retain edit and delete actions" do
      visit admin_pictures_path

      assert_selector "tr.picture img", count: 2 do |image|
        image.evaluate_script("this.complete && this.naturalWidth > 0")
      end

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "tr.picture", count: 3

      picture = Picture.find_by!(title: "conney-the-corgi")

      within "#picture_#{picture.id}" do
        assert_selector "img" do |image|
          image.evaluate_script("this.complete && this.naturalWidth > 0")
        end

        find(".edit a").click
      end

      assert_current_path edit_admin_picture_path(picture)

      fill_in "Alt Text", with: "New upload metadata"

      click_button "Submit"

      assert_current_path edit_admin_picture_path(picture)
      assert_equal "New upload metadata", picture.reload.alt_text

      visit admin_pictures_path

      within "#picture_#{picture.id}" do
        accept_confirm { find(".delete a").click }
      end

      assert_current_path admin_pictures_path
      assert_selector "tr.picture", count: 2
      assert_not Picture.exists?(picture.id)
    end

    test "direct upload failure allows selecting the same file again" do
      visit admin_pictures_path

      page.execute_script(<<~JS)
        const originalOpen = XMLHttpRequest.prototype.open;
        const originalSend = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.open = function(method, url, ...args) {
          this.uploadURL = url;
          return originalOpen.call(this, method, url, ...args);
        };
        XMLHttpRequest.prototype.send = function(...args) {
          if (String(this.uploadURL).includes('/rails/active_storage/direct_uploads')) {
            XMLHttpRequest.prototype.open = originalOpen;
            XMLHttpRequest.prototype.send = originalSend;
            this.dispatchEvent(new Event('error'));
          } else {
            return originalSend.apply(this, args);
          }
        };
      JS

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "[role=alert]", text: "Unable to upload the image. Please try again."
      assert_no_text "Uploading…"
      assert_selector "tr.picture", count: 2

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "tr.picture", count: 3
      assert_no_text "Uploading…"
      assert Picture.find_by!(title: "conney-the-corgi").image.attached?
    end

    test "disconnect cancels a pending save and ignores its late result after reconnect" do
      visit admin_pictures_path

      page.execute_script(<<~JS)
        const originalFetch = window.fetch.bind(window);
        window.fetch = (url, options) => {
          if (url === '/admin/pictures' && options?.method === 'POST') {
            window.fetch = originalFetch;
            window.pendingUploadSignal = options.signal;
            return new Promise(resolve => { window.resolveOldUpload = resolve; });
          }
          return originalFetch(url, options);
        };
      JS

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector ".pictures-manager" do
        page.evaluate_script("Boolean(window.pendingUploadSignal)")
      end

      assert_text "Uploading…"

      page.execute_script(<<~JS)
        window.uploadManager = document.querySelector('.pictures-manager');
        window.uploadManager.removeAttribute('data-controller');
      JS

      assert_selector ".pictures-manager" do
        page.evaluate_script("window.pendingUploadSignal.aborted")
      end

      assert_no_text "Uploading…"

      page.execute_script("window.uploadManager.setAttribute('data-controller', 'picture-uploads')")

      page.execute_script(<<~JS)
        window.resolveOldUpload(new Response('<tr class="picture"><td>Stale upload</td></tr>', {
          status: 200, headers: {'Content-Type': 'text/html'}
        }));
      JS

      assert_no_text "Stale upload"

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "tr.picture", count: 3
      assert_no_text "Uploading…"
      assert_equal 1, Picture.where(title: "conney-the-corgi").count
    end

    test "first upload replaces the empty list message" do
      Picture.destroy_all

      visit admin_pictures_path

      assert_selector ".no-items", text: "There are no pictures to display."
      assert_no_selector "tr.picture"

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "tr.picture", count: 1
      assert_no_selector ".no-items"

      refresh

      assert_link "conney-the-corgi"
      assert_no_selector ".no-items"
    end

    test "list retains its page size and server search and pagination after upload" do
      24.times do |index|
        Picture.create!(title: "Older photograph #{index}", image: pictures(:conney).image.blob,
          created_at: (index + 1).days.ago)
      end

      visit admin_pictures_path

      assert_selector "tr.picture", count: 25

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_link "conney-the-corgi"
      assert_selector "tr.picture", count: 25

      refresh

      assert_link "conney-the-corgi"
      assert_selector "tr.picture", count: 25

      visit admin_pictures_path(page: 2)

      assert_selector "tr.picture", count: 2

      visit admin_pictures_path(q: { title_cont: "conney-the-corgi" })

      assert_selector "tr.picture", count: 1
      assert_link "conney-the-corgi"
    end

    test "disconnect aborts a pending Active Storage request and reconnect can upload" do
      visit admin_pictures_path

      page.execute_script(<<~JS)
        const originalOpen = XMLHttpRequest.prototype.open;
        const originalSend = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.open = function(method, url, ...args) {
          this.uploadURL = url;
          return originalOpen.call(this, method, url, ...args);
        };
        XMLHttpRequest.prototype.send = function(...args) {
          if (String(this.uploadURL).includes('/rails/active_storage/direct_uploads')) {
            XMLHttpRequest.prototype.open = originalOpen;
            XMLHttpRequest.prototype.send = originalSend;
            const originalAbort = this.abort.bind(this);
            this.abort = () => { window.blobUploadAborted = true; originalAbort(); };
            window.blobUploadPending = true;
          } else {
            return originalSend.apply(this, args);
          }
        };
      JS

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector ".pictures-manager" do
        page.evaluate_script("Boolean(window.blobUploadPending)")
      end

      assert_text "Uploading…"

      page.execute_script(<<~JS)
        window.uploadManager = document.querySelector('.pictures-manager');
        window.uploadManager.removeAttribute('data-controller');
      JS

      assert_selector ".pictures-manager" do
        page.evaluate_script("Boolean(window.blobUploadAborted)")
      end

      assert_no_text "Uploading…"
      assert_no_selector "[role=alert]"

      page.execute_script("window.uploadManager.setAttribute('data-controller', 'picture-uploads')")

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "tr.picture", count: 3
      assert_equal 1, Picture.where(title: "conney-the-corgi").count
    end

    test "non-image selection shows an error without adding a picture" do
      visit admin_pictures_path

      attach_file Rails.root.join("test/fixtures/pages.yml"), make_visible: true

      assert_selector "[role=alert]", text: "Please choose an image."
      assert_selector "tr.picture", count: 2
      assert_equal 2, Picture.count
    end

    test "picture metadata can be edited and the picture deleted" do
      picture = pictures(:conney)

      visit edit_admin_picture_path(picture)

      fill_in "Title", with: "Updated photograph"
      fill_in "Alt Text", with: "A corgi outdoors"

      click_button "Submit"

      assert_current_path edit_admin_picture_path(picture.reload)
      assert_equal "A corgi outdoors", picture.reload.alt_text

      visit admin_picture_path(picture)

      accept_confirm { click_link "Delete" }

      assert_current_path admin_pictures_path
      assert_not Picture.exists?(picture.id)
    end

    test "a rejected picture save displays the server message without updating the list" do
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

      attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true

      assert_selector "[role=alert]", text: "Picture was rejected"
      assert_no_text "Uploading…"
      assert_selector "tr.picture", count: 2
      assert_equal 2, Picture.count
    end
  end
end
