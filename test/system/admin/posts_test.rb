require "application_system_test_case"
require_relative "../../support/editor_system_test_helpers"
require_relative "../../support/anonymous_browser_helpers"
require_relative "../../support/system_test_uploads"

module Admin
  class PostsTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include AnonymousBrowserHelpers
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
      attach_images_to_pictures!
    end

    test "a rejected new post retains its draft fields and can be corrected and saved" do
      draft = {
        body: "<p>Keep this unpublished draft.</p>",
        style: "p { color: purple; }",
        script: "window.recoveredPostDraft = true;"
      }
      tags = 'recovery, "design, art", C++'

      visit new_admin_post_path

      draft.each { |field, value| fill_in_ace "post_#{field}", with: value }

      fill_in "post_tag_list", with: tags

      uncheck "post_visible", allow_label_click: true

      assert_no_difference "Post.count" do
        click_button "Submit"

        assert_text "Title can't be blank"
      end

      assert_field "post_title", with: ""
      assert_post_draft draft, tags: tags, visible: false

      fill_in "Title", with: "Recovered post draft"

      click_button "Submit"

      assert_text "Post was successfully created."

      saved = Post.find_by!(title: "Recovered post draft")

      assert_current_path admin_post_path(saved)
      assert_equal draft.stringify_keys, saved.attributes.slice(*draft.keys.map(&:to_s))
      assert_equal [ "C++", "design, art", "recovery" ], saved.tag_list.sort
      assert_not saved.visible

      visit edit_admin_post_path(saved)

      assert_field "post_title", with: saved.title
      assert_post_draft draft, tags: tags, visible: false
    end

    test "a rejected post update preserves stored content and saves corrected draft values" do
      record = posts(:first_post)

      record.update!(visible: false)

      original_attributes = record.attributes
      original_tags = record.tags.order(:name).pluck(:name)
      draft = {
        body: "<p>Keep this edited body.</p>",
        style: "p { color: teal; }",
        script: "window.recoveredPostEdit = true;"
      }
      tags = "edited, C++"

      visit edit_admin_post_path(record)

      fill_in "Title", with: ""

      draft.each { |field, value| fill_in_ace "post_#{field}", with: value }

      fill_in "post_tag_list", with: tags

      check "post_visible", allow_label_click: true

      click_button "Submit"

      assert_text "Title can't be blank"
      assert_equal original_attributes, record.reload.attributes
      assert_equal original_tags, record.tags.order(:name).pluck(:name)
      assert_field "post_title", with: ""
      assert_post_draft draft, tags: tags, visible: true

      fill_in "Title", with: "Recovered edited post"

      click_button "Submit"

      assert_text "Post was successfully updated."

      saved = Post.find(record.id)

      assert_current_path edit_admin_post_path(saved)
      assert_equal "Recovered edited post", saved.title
      assert_equal draft.stringify_keys, saved.attributes.slice(*draft.keys.map(&:to_s))
      assert_equal [ "C++", "edited" ], saved.tag_list.sort
      assert saved.visible

      visit edit_admin_post_path(saved)

      assert_post_draft draft, tags: tags, visible: true
    end

    test "post visibility changes persist and control anonymous listings and direct access" do
      record = posts(:first_post)

      [ false, true, false ].each do |visible|
        visit edit_admin_post_path(record)

        if visible
          check "post_visible", allow_label_click: true
        else
          uncheck "post_visible", allow_label_click: true
        end

        click_button "Submit"

        assert_current_path edit_admin_post_path(record)
        assert_equal visible, record.reload.visible

        visit edit_admin_post_path(record)

        visible ? assert_checked_field("post_visible") : assert_unchecked_field("post_visible")

        with_anonymous_browser do
          visit root_path

          assert_no_selector "body.logged-in"

          # A visible control prevents an empty/broken listing from satisfying exclusion.
          assert_selector "article#post-#{posts(:second_post).slug}"

          if visible
            within "article#post-#{record.slug}" do
              click_link record.title
            end
          else
            assert_no_selector "article#post-#{record.slug}"

            visit post_path(record)
          end

          assert_current_path post_path(record)

          if visible
            assert_selector "article#post-#{record.slug} .body-content", text: "My first post."
          else
            assert_no_selector "article#post-#{record.slug}"
            assert_no_text "My first post."
          end
        end
      end
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

    test "picture selector reports a failed load and can retry" do
      visit new_admin_post_path

      page.execute_script(<<~JS)
        const originalFetch = window.fetch.bind(window);
        window.fetch = (...args) => {
          window.fetch = originalFetch;
          return Promise.reject(new TypeError('Simulated network failure'));
        };
      JS

      click_button "Insert Picture"

      assert_selector ".picture-inserter [role=alert]", text: "Unable to load pictures. Please try again."
      assert_button "Insert Picture", disabled: false

      click_button "Insert Picture"

      assert_selector ".picture-selector-modal"

      overlay = find(".picture-selector-modal-overlay")

      assert_selector ".picture-selector-modal-picture img", count: 2 do |image|
        image.evaluate_script("this.complete && this.naturalWidth > 0")
      end

      # Move off its covered center before clicking the backdrop.
      page.driver.browser.action.move_to(overlay.native).move_by(-(overlay.native.size.width / 2) + 10, 0).click.perform

      assert_no_selector ".picture-selector-modal"
      assert_selector ".picture-inserter button[data-picture-selector-target=button]:focus"
    end

    test "picture selection works from the keyboard without submitting the form" do
      visit new_admin_post_path

      fill_in_ace "post_body", with: "<p>Keyboard selection.</p>"

      click_button "Insert Picture"

      assert_selector ".picture-selector-close-button:focus"

      page.send_keys :tab

      assert_selector ".picture-selector-modal-picture:focus"

      page.send_keys :enter

      assert_no_selector ".picture-selector-modal"
      assert_current_path new_admin_post_path

      body = find_field("post_body", visible: :all).value

      assert_equal 1, Nokogiri::HTML.fragment(body).css("img").length
    end

    test "disconnect cancels a pending selector load and reconnect selects only once" do
      visit new_admin_post_path

      fill_in_ace "post_body", with: "<p>Reconnect selection.</p>"

      page.execute_script(<<~JS)
        const originalFetch = window.fetch.bind(window);
        window.fetch = (url, options) => {
          window.fetch = originalFetch;
          return new Promise((resolve, reject) => {
            options.signal.addEventListener('abort', () => reject(new DOMException('Aborted', 'AbortError')));
          });
        };
      JS

      click_button "Insert Picture"

      assert_button "Insert Picture", disabled: true

      page.execute_script(<<~JS)
        window.detachedSelector = document.querySelector('.picture-inserter');
        window.selectorParent = window.detachedSelector.parentElement;
        window.detachedSelector.remove();
      JS

      assert_no_selector ".picture-inserter"

      page.execute_script("window.selectorParent.append(window.detachedSelector)")

      assert_button "Insert Picture", disabled: false

      select_picture pictures(:conney)

      assert_no_selector ".picture-inserter [role=alert]"

      body = find_field("post_body", visible: :all).value

      assert_equal 1, Nokogiri::HTML.fragment(body).css("img").length
    end

    private

    def assert_post_draft(editors, tags:, visible:)
      editors.each do |field, value|
        assert_field "post_#{field}", with: value, visible: :all

        assert_selector "#post_#{field}-editor.ace_editor" do |editor|
          editor.evaluate_script("this.env.editor.getValue()") == value
        end
      end

      expected_tags = ActsAsTaggableOn.default_parser.new(tags).parse.sort
      actual_tags = ActsAsTaggableOn.default_parser.new(find_field("post_tag_list").value).parse.sort

      assert_equal expected_tags, actual_tags

      visible ? assert_checked_field("post_visible") : assert_unchecked_field("post_visible")
    end
  end
end
