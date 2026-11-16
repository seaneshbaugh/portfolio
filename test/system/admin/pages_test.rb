require "application_system_test_case"
require_relative "../../support/editor_system_test_helpers"
require_relative "../../support/anonymous_browser_helpers"

module Admin
  class PagesTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include AnonymousBrowserHelpers

    setup do
      @user = users(:sean_eshbaugh)
      sign_in @user
    end

    test "page visibility changes persist and control anonymous navigation and direct access" do
      record = pages(:about)

      [ false, true, false ].each do |visible|
        visit edit_admin_page_path(record)

        check "page_show_in_menu", allow_label_click: true

        if visible
          check "page_visible", allow_label_click: true
        else
          uncheck "page_visible", allow_label_click: true
        end

        click_button "Submit"

        assert_current_path edit_admin_page_path(record)
        assert_equal visible, record.reload.visible
        assert record.show_in_menu

        visit edit_admin_page_path(record)

        visible ? assert_checked_field("page_visible") : assert_unchecked_field("page_visible")

        assert_checked_field "page_show_in_menu"

        with_anonymous_browser do
          visit root_path

          assert_no_selector "body.logged-in"

          within ".main-header-nav" do
            if visible
              assert_link record.title, href: page_path(record)

              click_link record.title
            else
              assert_no_link record.title, href: page_path(record)
            end
          end

          visit page_path(record) unless visible

          assert_current_path page_path(record)

          if visible
            assert_selector ".page .body-content", text: "About me."
          else
            assert_no_selector ".page .body-content"
            assert_no_text "About me."
          end
        end
      end
    end

    test "a published page stays accessible when removed from the menu" do
      record = pages(:about)

      [ false, true ].each do |in_menu|
        visit edit_admin_page_path(record)

        assert_checked_field "page_visible"

        if in_menu
          check "page_show_in_menu", allow_label_click: true
        else
          uncheck "page_show_in_menu", allow_label_click: true
        end

        click_button "Submit"

        assert_current_path edit_admin_page_path(record)
        assert_equal in_menu, record.reload.show_in_menu
        assert record.visible

        visit edit_admin_page_path(record)

        assert_checked_field "page_visible"

        in_menu ? assert_checked_field("page_show_in_menu") : assert_unchecked_field("page_show_in_menu")

        with_anonymous_browser do
          visit root_path

          assert_no_selector "body.logged-in"

          within ".main-header-nav" do
            if in_menu
              assert_link record.title, href: page_path(record)
            else
              assert_no_link record.title, href: page_path(record)
            end
          end

          visit page_path(record)

          assert_current_path page_path(record)
          assert_selector ".page .body-content", text: "About me."
        end
      end
    end

    test "user creates a page" do
      visit admin_pages_path

      click_link "New Page"

      fill_in "Title", with: "Test Page"

      fill_in_ace "page_body", with: "<p>Testing 1 2 3</p>"
      fill_in_ace "page_style", with: "p { color: red; }"
      fill_in_ace "page_script", with: "window.pageTest = true;"

      click_button "Submit"

      assert_current_path admin_page_path(Page.last)

      assert_text "Test Page"

      saved = Page.find_by!(title: "Test Page")

      assert_equal "<p>Testing 1 2 3</p>", saved.body
      assert_equal "p { color: red; }", saved.style
      assert_equal "window.pageTest = true;", saved.script

      visit edit_admin_page_path(saved)

      assert_field "page_body", with: saved.body, visible: :all

      fill_in_ace "page_body", with: "<p>Updated body.</p>"

      click_button "Submit"

      assert_current_path edit_admin_page_path(saved)
      assert_equal "<p>Updated body.</p>", saved.reload.body
    end

    test "invalid input preserves editor contents for correction" do
      visit new_admin_page_path

      fill_in_ace "page_body", with: "<p>Keep this draft.</p>"

      click_button "Submit"

      assert_text "Title can't be blank"
      assert_field "page_body", with: "<p>Keep this draft.</p>", visible: :all

      fill_in "Title", with: "Corrected draft"

      click_button "Submit"

      saved = Page.find_by!(title: "Corrected draft")

      assert_current_path admin_page_path(saved)
      assert_equal "<p>Keep this draft.</p>", saved.body
    end

    test "admin deletes a page with confirmation" do
      record = pages(:about)

      visit admin_page_path(record)

      accept_confirm { click_link "Delete" }

      assert_current_path admin_pages_path
      assert_not Page.exists?(record.id)
    end
  end
end
