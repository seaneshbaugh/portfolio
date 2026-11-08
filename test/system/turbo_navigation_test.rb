require "application_system_test_case"
require_relative "../support/editor_system_test_helpers"
require_relative "../support/system_test_uploads"

class TurboNavigationTest < ApplicationSystemTestCase
  include EditorSystemTestHelpers
  include SystemTestUploads

  setup do
    sign_in users(:sean_eshbaugh)
    attach_images_to_pictures!
  end

  test "Turbo navigation and Back restore an editor draft with one picture insertion" do
    visit admin_pages_path
    page.execute_script("window.navigationMarker = 'same document'")
    click_link "New Page"
    assert_current_path new_admin_page_path
    assert_equal "same document", page.evaluate_script("window.navigationMarker")
    fill_in "Title", with: "Restored page draft"
    fill_in_ace "page_body", with: "<p>Preserved draft.</p>"
    page.execute_script("window.previousEditor = document.querySelector('#page_body-editor').env.editor")
    click_link "Cancel"
    assert_current_path admin_pages_path
    assert_link "New Page"
    assert page.evaluate_script("window.previousEditor.destroyed && window.previousEditor.session.destroyed")
    page.go_back
    assert_current_path new_admin_page_path
    assert_selector "#page_body-editor.ace_editor"
    assert_field "Title", with: "Restored page draft"
    assert_field "page_body", with: "<p>Preserved draft.</p>", visible: :all
    select_picture pictures(:conney)
    body = find_field("page_body", visible: :all).value
    assert_equal 1, Nokogiri::HTML.fragment(body).css("img").length
    click_button "Submit"
    saved = Page.find_by!(title: "Restored page draft")
    assert_current_path admin_page_path(saved)
    assert_equal body, saved.body
    assert_selector ".flash-message"
    click_link "Edit"
    assert_selector "#page_body-editor.ace_editor"
    page.go_back
    assert_current_path admin_page_path(saved)
    assert_no_selector ".flash-message"
  end

  test "gallery draft and flags survive history restoration with the selector closed" do
    visit admin_galleries_path
    click_link "New Gallery"
    fill_in "Name", with: "History gallery"
    select_picture pictures(:conney), button: "Add Picture"
    select_picture pictures(:cowboy), button: "Add Picture"
    within all(".gallery-picture").last do
      click_button "Move up"
      check "Featured", allow_label_click: true
      uncheck "Visible", allow_label_click: true
    end
    click_button "Add Picture"
    assert_selector ".picture-selector-modal"
    page.go_back
    assert_current_path admin_galleries_path
    assert_link "New Gallery"
    page.go_forward
    assert_current_path new_admin_gallery_path
    assert_field "Name", with: "History gallery"
    assert_no_selector ".picture-selector-modal"
    assert_button "Add Picture", disabled: false
    assert_selector ".gallery-picture", count: 2
    within all(".gallery-picture").first do
      assert_selector "input[name$='[picture_id]'][value='#{pictures(:cowboy).id}']", visible: :all
      assert_checked_field "Featured", visible: :all
      assert_unchecked_field "Visible", visible: :all
    end
    select_picture pictures(:conney), button: "Add Picture"
    assert_selector ".gallery-picture", count: 3
    click_button "Submit"
    saved = Gallery.find_by!(name: "History gallery")
    assert_current_path admin_gallery_path(saved)
    assert_equal [ pictures(:cowboy).id, pictures(:conney).id, pictures(:conney).id ], saved.gallery_pictures.by_order.pluck(:picture_id)
  end

  test "pending uploads are aborted before caching and can retry on Back" do
    visit admin_pictures_path
    page.execute_script(<<~JS)
      const originalFetch = window.fetch.bind(window);
      window.fetch = (url, options) => {
        if (url === '/admin/pictures' && options?.method === 'POST') {
          window.fetch = originalFetch;
          window.uploadSignal = options.signal;
          return new Promise((resolve, reject) => options.signal.addEventListener('abort', () => reject(new DOMException('Aborted', 'AbortError'))));
        }
        return originalFetch(url, options);
      };
    JS
    attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true
    assert_selector ".pictures-manager" do
      page.evaluate_script("Boolean(window.uploadSignal)")
    end
    within ".main-header-nav" do
      click_link "Pages"
    end
    assert_current_path admin_pages_path
    assert_link "New Page"
    assert page.evaluate_script("window.uploadSignal.aborted")
    page.go_back
    assert_current_path admin_pictures_path
    assert_no_text "Uploading…"
    assert_no_selector "[role=alert]"
    attach_file fixture_file_path("conney-the-corgi.jpg"), make_visible: true
    assert_selector "tr.picture", count: 3
    assert_equal 1, Picture.where(title: "conney-the-corgi").count
  end

  test "lightbox closes before caching and opens once after Forward" do
    galleries(:salt_plains).update!(visible: true)
    visit pictures_path
    click_link "Salt Plains"
    assert_current_path picture_path(galleries(:salt_plains))
    find("a.lightbox", match: :first).click
    assert_selector ".glightbox-container"
    page.go_back
    assert_current_path pictures_path
    assert_link "Salt Plains"
    assert_no_selector ".glightbox-container"
    assert_no_selector "html.glightbox-open, body.glightbox-open"
    page.go_forward
    assert_current_path picture_path(galleries(:salt_plains))
    find("a.lightbox", match: :first).click
    assert_selector ".glightbox-container", count: 1
    find(".gclose").click
    assert_no_selector ".glightbox-container"
  end

  test "CMS scripts get fresh documents and DOMContentLoaded on every visit" do
    pages(:about).update!(script: <<~JS)
      const cmsDocument = true;
      document.addEventListener('DOMContentLoaded', () => { document.body.dataset.cmsInitializations = '1'; });
    JS
    visit root_path
    page.execute_script("window.oldDocumentMarker = true")
    within ".main-header-nav" do
      click_link "About"
    end
    assert_current_path page_path(pages(:about))
    assert_selector "body[data-cms-initializations='1'][data-turbo=false]"
    assert page.evaluate_script("typeof window.oldDocumentMarker === 'undefined'")
    assert_selector "meta[name=turbo-visit-control][content=reload]", visible: :all
    page.execute_script("window.cmsDocumentMarker = true")
    within ".main-header-nav" do
      click_link "Home"
    end
    assert_current_path root_path
    assert page.evaluate_script("typeof window.cmsDocumentMarker === 'undefined'")
    within ".main-header-nav" do
      click_link "About"
    end
    assert_selector "body[data-cms-initializations='1']"
  end

  test "Turbo delete confirmation can cancel before performing the delete" do
    picture = pictures(:conney)
    visit admin_picture_path(picture)
    page.execute_script("window.navigationMarker = 'same document'")
    dismiss_confirm { click_link "Delete" }
    assert_current_path admin_picture_path(picture)
    assert Picture.exists?(picture.id)
    accept_confirm { click_link "Delete" }
    assert_current_path admin_pictures_path
    assert_not Picture.exists?(picture.id)
    assert_equal "same document", page.evaluate_script("window.navigationMarker")
  end

  test "layout and authentication changes reload the document" do
    visit admin_pages_path
    page.execute_script("window.adminDocumentMarker = true")
    within ".main-header-nav" do
      find("a[href='#{root_path}']").click
    end
    assert_current_path root_path
    assert_link "First Post"
    assert page.evaluate_script("typeof window.adminDocumentMarker === 'undefined'")
    page.execute_script("window.publicDocumentMarker = true")
    within ".main-header-nav" do
      click_link "Admin"
    end
    assert_current_path admin_root_path
    assert page.evaluate_script("typeof window.publicDocumentMarker === 'undefined'")
    within ".main-header-nav" do
      find("a[href='#{root_path}']").click
    end
    assert_current_path root_path
    assert_link "First Post"
    page.execute_script("window.logoutDocumentMarker = true")
    click_link "Logout"
    assert_current_path root_path
    within ".main-header-nav" do
      assert_no_link "Admin"
    end
    assert page.evaluate_script("typeof window.logoutDocumentMarker === 'undefined'")
  end

  test "post scripts and inline body scripts opt out of Turbo" do
    post = posts(:first_post)
    post.update!(script: "window.postScriptLoaded = true;")
    visit root_path
    assert_selector "body[data-turbo=false]"
    assert page.evaluate_script("window.postScriptLoaded")
    post.update!(script: "", body: "<p>Inline script content.</p><script>window.inlineScriptLoaded = true;</script>")
    visit post_path(post)
    assert_selector "body[data-turbo=false]"
    assert_selector "meta[name=turbo-visit-control][content=reload]", visible: :all
    assert page.evaluate_script("window.inlineScriptLoaded")
  end

  test "native select keeps its value after history restoration" do
    visit admin_users_path
    assert_selector "select#q_roles_name_eq", count: 1
    select "Admin", from: "q_roles_name_eq"
    assert_field "q_roles_name_eq", with: "admin", visible: :all
    within ".main-header-nav" do
      click_link "Pages"
    end
    assert_link "New Page"
    page.go_back
    assert_current_path admin_users_path
    assert_selector "select#q_roles_name_eq", count: 1
    assert_field "q_roles_name_eq", with: "admin", visible: :all
    find("select#q_roles_name_eq option[value='']").select_option
    assert_field "q_roles_name_eq", with: ""
  end
end
