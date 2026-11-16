require "application_system_test_case"
require_relative "../../support/editor_system_test_helpers"
require_relative "../../support/system_test_uploads"
require_relative "../../support/anonymous_browser_helpers"

module Admin
  class GalleriesTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include SystemTestUploads
    include AnonymousBrowserHelpers

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test "gallery publication changes persist and control anonymous listing and direct access" do
      gallery = galleries(:salt_plains)

      [ false, true, false ].each do |visible|
        visit edit_admin_gallery_path(gallery)

        if visible
          check "gallery_visible", allow_label_click: true
        else
          uncheck "gallery_visible", allow_label_click: true
        end

        click_button "Submit"

        assert_current_path edit_admin_gallery_path(gallery)
        assert_equal visible, gallery.reload.visible

        visit edit_admin_gallery_path(gallery)

        visible ? assert_checked_field("gallery_visible") : assert_unchecked_field("gallery_visible")

        with_anonymous_browser do
          visit pictures_path

          assert_no_selector "body.logged-in"
          assert_selector ".galleries"

          if visible
            within ".galleries" do
              click_link gallery.name
            end

            assert_current_path picture_path(gallery)
            assert_selector "#gallery-#{gallery.slug} .gallery-pictures .gallery-picture", count: 2
          else
            assert_no_link gallery.name, href: picture_path(gallery)

            visit picture_path(gallery)

            assert_current_path picture_path(gallery)
            assert_no_selector "#gallery-#{gallery.slug}"
            assert_no_selector ".gallery-pictures"
          end
        end
      end
    end

    test "hiding a featured membership falls back to the visible cover and restoring it restores the cover" do
      gallery = galleries(:salt_plains)
      featured = pictures(:conney)
      fallback = pictures(:cowboy)

      [ true, false, true ].each do |visible|
        visit edit_admin_gallery_path(gallery)

        check "gallery_visible", allow_label_click: true

        within gallery_row(featured) do
          assert_checked_field "Featured", visible: :all

          if visible
            check "Visible", allow_label_click: true
          else
            uncheck "Visible", allow_label_click: true
          end
        end

        click_button "Submit"

        assert_current_path edit_admin_gallery_path(gallery)

        membership = gallery.gallery_pictures.find_by!(picture: featured)

        assert_equal visible, membership.visible
        assert membership.featured
        assert gallery.reload.visible

        visit edit_admin_gallery_path(gallery)

        within gallery_row(featured) do
          visible ? assert_checked_field("Visible", visible: :all) : assert_unchecked_field("Visible", visible: :all)

          assert_checked_field "Featured", visible: :all
        end

        with_anonymous_browser do
          visit pictures_path

          assert_no_selector "body.logged-in"

          cover = visible ? featured : fallback

          assert_selector ".gallery-preview a[href='#{picture_path(gallery)}'] img[src='#{cover.medium_image_path}']" do |image|
            image.evaluate_script("this.complete && this.naturalWidth > 0")
          end

          click_link gallery.name
          assert_current_path picture_path(gallery)
          assert_selector ".gallery-pictures a[href='#{fallback.original_image_path}']"

          if visible
            assert_selector ".gallery-pictures a[href='#{featured.original_image_path}']"
          else
            assert_no_selector ".gallery-pictures a[href='#{featured.original_image_path}']"
          end
        end
      end
    end

    test "empty and all-hidden published galleries are omitted without breaking other gallery cards" do
      empty = Gallery.create!(name: "Empty published gallery", visible: true, order: 1)
      control = Gallery.create!(name: "Visible control gallery", visible: true, order: 2)

      GalleryPicture.create!(gallery: control, picture: pictures(:cowboy), visible: true, featured: true, order: 0)

      gallery = galleries(:salt_plains)

      visit edit_admin_gallery_path(gallery)

      check "gallery_visible", allow_label_click: true

      [ pictures(:conney), pictures(:cowboy) ].each do |picture|
        within gallery_row(picture) do
          uncheck "Visible", allow_label_click: true
        end
      end

      click_button "Submit"

      assert_current_path edit_admin_gallery_path(gallery)
      assert gallery.reload.visible
      assert_not gallery.gallery_pictures.reload.any?(&:visible)

      visit edit_admin_gallery_path(gallery)

      assert_checked_field "gallery_visible"

      [ pictures(:conney), pictures(:cowboy) ].each do |picture|
        within gallery_row(picture) do
          assert_unchecked_field "Visible", visible: :all
        end
      end

      with_anonymous_browser do
        visit pictures_path

        assert_no_selector "body.logged-in"
        assert_selector ".galleries .gallery", count: 1
        assert_no_link empty.name, href: picture_path(empty)
        assert_no_link gallery.name, href: picture_path(gallery)

        assert_selector ".gallery-preview a[href='#{picture_path(control)}'] img" do |image|
          image.evaluate_script("this.complete && this.naturalWidth > 0")
        end

        click_link control.name

        assert_current_path picture_path(control)
        assert_selector ".gallery-pictures .gallery-picture", count: 1
      end
    end

    test "create a gallery with selected pictures and remove a saved membership" do
      visit new_admin_gallery_path

      fill_in "Name", with: "Browser gallery"
      fill_in_ace "gallery_description", with: "<p>Gallery description.</p>"

      select_picture pictures(:conney), button: "Add Picture"
      select_picture pictures(:cowboy), button: "Add Picture"

      within all(".gallery-picture").first do
        check "Featured", allow_label_click: true
      end

      click_button "Submit"

      gallery = Gallery.find_by!(name: "Browser gallery")

      assert_current_path admin_gallery_path(gallery)
      assert_equal [ pictures(:conney).id, pictures(:cowboy).id ], gallery.gallery_pictures.by_order.pluck(:picture_id)
      assert_equal pictures(:conney), gallery.featured_picture

      visit edit_admin_gallery_path(gallery)

      within all(".gallery-picture").first do
        click_button "Remove picture"
      end

      assert_selector ".gallery-picture", count: 1

      click_button "Submit"

      assert_current_path edit_admin_gallery_path(gallery)
      assert_equal [ pictures(:cowboy).id ], gallery.gallery_pictures.reload.pluck(:picture_id)

      visit admin_gallery_path(gallery)

      accept_confirm { click_link "Delete" }

      assert_current_path admin_galleries_path
      assert_not Gallery.exists?(gallery.id)
    end

    test "drag reordering and featured and visible flags persist after reopening" do
      gallery = galleries(:salt_plains)

      visit edit_admin_gallery_path(gallery)

      rows = all(".gallery-picture", count: 2)

      rows.first.execute_script('this.scrollIntoView({block: "start"})')

      handle = rows.first.find(".gallery-picture-drag")

      page.driver.browser.action.move_to(handle.native).click_and_hold.pause(duration: 0.2)
        .move_by(0, 10).pause(duration: 0.2).move_to(rows.last.native, y: 30).pause(duration: 0.2).release.perform

      # Gecko's WebDriver sends dragstart/dragover but omits drop/dragend.
      # Complete the DOM drop event without changing controller state or fields.
      rows.last.execute_script(<<~JS)
        this.dispatchEvent(new DragEvent('drop', {
          bubbles: true, cancelable: true, dataTransfer: new DataTransfer(),
          clientY: this.getBoundingClientRect().bottom - 1
        }));
      JS

      assert_no_selector ".gallery-picture.dragging", visible: :all
      assert_selector ".gallery-picture:first-child input[name$='[picture_id]'][value='#{pictures(:cowboy).id}']", visible: :all

      within gallery_row(pictures(:cowboy)) do
        check "Featured", allow_label_click: true
      end

      within gallery_row(pictures(:conney)) do
        find("label", text: "Visible", exact_text: true).find("span").click

        assert_unchecked_field "Visible", visible: :all
      end

      click_button "Submit"

      assert_current_path edit_admin_gallery_path(gallery)

      memberships = gallery.gallery_pictures.reload.by_order.to_a

      assert_equal [ pictures(:cowboy).id, pictures(:conney).id ], memberships.map(&:picture_id)
      assert memberships.first.featured
      assert_not memberships.last.visible
      assert_not memberships.last.featured

      visit edit_admin_gallery_path(gallery)

      within gallery_row(pictures(:cowboy)) do
        assert_checked_field "Featured", visible: :all
      end

      within gallery_row(pictures(:conney)) do
        assert_unchecked_field "Visible", visible: :all
      end
    end

    test "invalid gallery retains selections and unsaved selections can be removed" do
      visit new_admin_gallery_path

      select_picture pictures(:conney), button: "Add Picture"

      click_button "Submit"

      assert_text "Name can't be blank"
      assert_selector ".gallery-picture", count: 1

      within ".gallery-picture" do
        click_button "Remove picture"
      end

      assert_no_selector ".gallery-picture"

      fill_in "Name", with: "Corrected empty gallery"

      click_button "Submit"

      gallery = Gallery.find_by!(name: "Corrected empty gallery")

      assert_current_path admin_gallery_path(gallery)
      assert_empty gallery.gallery_pictures
    end

    test "keyboard and button ordering preserve membership fields and featured exclusivity" do
      gallery = galleries(:salt_plains)

      visit edit_admin_gallery_path(gallery)

      original_name = gallery_row(pictures(:cowboy)).find("input[name$='[picture_id]']", visible: :all)[:name]

      button = gallery_row(pictures(:cowboy)).find_button("Move up")

      button.execute_script("this.focus()")

      page.send_keys :enter

      assert_selector ".gallery-picture:first-child input[name$='[picture_id]'][value='#{pictures(:cowboy).id}']", visible: :all
      assert_equal original_name, gallery_row(pictures(:cowboy)).find("input[name$='[picture_id]']", visible: :all)[:name]
      assert_selector "button:focus", text: /move up/i
      assert_selector "[role=status]", text: "moved to position 1 of 2"
      assert_current_path edit_admin_gallery_path(gallery)

      within gallery_row(pictures(:cowboy)) do
        check "Featured", allow_label_click: true
        click_button "Move down"
      end

      within gallery_row(pictures(:conney)) do
        assert_unchecked_field "Featured", visible: :all
      end

      click_button "Submit"

      assert_current_path edit_admin_gallery_path(gallery)
      assert_equal [ pictures(:conney).id, pictures(:cowboy).id ], gallery.gallery_pictures.reload.by_order.pluck(:picture_id)
      assert_equal pictures(:cowboy), gallery.featured_picture
    end

    test "duplicate selections keep unique fields when removing and adding pictures" do
      visit new_admin_gallery_path
      fill_in "Name", with: "Repeated pictures"
      select_picture pictures(:conney), button: "Add Picture"
      select_picture pictures(:cowboy), button: "Add Picture"
      select_picture pictures(:conney), button: "Add Picture"
      within all(".gallery-picture")[1] do
        click_button "Remove picture"
      end
      select_picture pictures(:cowboy), button: "Add Picture"
      ids = all(".gallery-picture input[id]", visible: :all).map { |input| input[:id] }
      assert_equal ids.uniq, ids
      assert_selector ".gallery-picture", count: 3
      assert_selector ".gallery-picture img", count: 3 do |image|
        image.evaluate_script("this.complete && this.naturalWidth > 0")
      end
      click_button "Submit"
      gallery = Gallery.find_by!(name: "Repeated pictures")
      assert_current_path admin_gallery_path(gallery)
      assert_equal [ pictures(:conney).id, pictures(:conney).id, pictures(:cowboy).id ], gallery.gallery_pictures.by_order.pluck(:picture_id)
      assert_equal [ 0, 1, 2 ], gallery.gallery_pictures.by_order.pluck(:order)
    end

    test "validation preserves saved removals and reordered unsaved fields" do
      gallery = galleries(:salt_plains)
      removed_id = gallery.gallery_pictures.find_by!(picture: pictures(:conney)).id

      visit edit_admin_gallery_path(gallery)

      within gallery_row(pictures(:conney)) do
        click_button "Remove picture"
      end

      select_picture pictures(:conney), button: "Add Picture"

      within all(".gallery-picture").last do
        click_button "Move up"
      end

      fill_in "Name", with: ""

      click_button "Submit"

      assert_text "Name can't be blank"
      assert_selector ".gallery-picture", count: 2
      assert_selector ".gallery-picture[hidden] input[name$='[_destroy]'][value='1']", visible: :all

      within all(".gallery-picture").first do
        assert_selector "input[name$='[picture_id]'][value='#{pictures(:conney).id}']", visible: :all
      end

      fill_in "Name", with: "Corrected gallery"

      click_button "Submit"

      assert_current_path edit_admin_gallery_path(gallery.reload)

      memberships = gallery.gallery_pictures.reload.by_order

      assert_equal [ pictures(:conney).id, pictures(:cowboy).id ], memberships.pluck(:picture_id)
      assert_not memberships.exists?(removed_id)
      assert_equal [ 0, 1 ], memberships.pluck(:order)
    end

    test "reconnect preserves drafts and adds each selected picture once" do
      visit new_admin_gallery_path

      fill_in "Name", with: "Reconnected gallery"

      select_picture pictures(:conney), button: "Add Picture"

      page.execute_script(<<~JS)
        window.galleryManager = document.querySelector('.gallery-pictures-container');
        window.galleryManager.removeAttribute('data-controller');
      JS

      assert_button "Add Picture", disabled: true

      page.execute_script("window.galleryManager.setAttribute('data-controller', 'gallery-pictures')")

      assert_button "Add Picture", disabled: false

      select_picture pictures(:cowboy), button: "Add Picture"

      assert_selector ".gallery-picture", count: 2

      click_button "Submit"

      gallery = Gallery.find_by!(name: "Reconnected gallery")

      assert_current_path admin_gallery_path(gallery)
      assert_equal [ pictures(:conney).id, pictures(:cowboy).id ], gallery.gallery_pictures.by_order.pluck(:picture_id)
    end

    private

    def gallery_row(picture)
      find(".gallery-picture input[name$='[picture_id]'][value='#{picture.id}']", visible: :all).find(:xpath, "..")
    end
  end
end
