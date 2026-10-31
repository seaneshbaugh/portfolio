require "application_system_test_case"
require_relative "../../support/editor_system_test_helpers"
require_relative "../../support/system_test_uploads"

module Admin
  class PostsTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test "post editors and picture insertion survive saving and reopening" do
      visit new_admin_post_path

      fill_in "Title", with: "Browser authored post"
      fill_in_ace "post_body", with: "<p>Browser authored content.</p>"
      fill_in_ace "post_style", with: "p { color: blue; }"
      fill_in_ace "post_script", with: "window.postTest = true;"
      fill_in "post_tag_list", with: "browser-test"

      picture = pictures(:conney)

      picture.update!(alt_text: 'Conney says "hello" & goodbye')

      select_picture picture

      click_button "Submit"

      saved = Post.find_by!(title: "Browser authored post")

      assert_current_path admin_post_path(saved)
      assert_equal users(:sean_eshbaugh), saved.user
      assert_includes saved.tag_list, "browser-test"

      image = Nokogiri::HTML.fragment(saved.body).at_css("img")

      assert_equal picture.alt_text, image["alt"]
      assert_includes image["src"], "/rails/active_storage/"
      assert_equal "p { color: blue; }", saved.style
      assert_equal "window.postTest = true;", saved.script

      visit edit_admin_post_path(saved)

      assert_field "post_body", with: saved.body, visible: :all

      fill_in_ace "post_body", with: "<p>Edited post content.</p>"

      click_button "Submit"

      assert_current_path edit_admin_post_path(saved)
      assert_equal "<p>Edited post content.</p>", saved.reload.body

      visit admin_post_path(saved)

      accept_confirm { click_link "Delete" }

      assert_current_path admin_posts_path
      assert_not Post.exists?(saved.id)
    end

    test "picture selector can close and reopen without inserting" do
      visit new_admin_post_path

      fill_in_ace "post_body", with: "<p>Unchanged.</p>"

      click_button "Insert Picture"

      assert_selector ".picture-selector-modal"

      click_button "Close picture selector"

      assert_no_selector ".picture-selector-modal"

      click_button "Insert Picture"

      assert_selector ".picture-selector-modal"

      page.send_keys :escape

      assert_no_selector ".picture-selector-modal"
      assert_field "post_body", with: "<p>Unchanged.</p>", visible: :all
    end
  end
end
