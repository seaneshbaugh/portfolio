require "application_system_test_case"
require_relative "../support/editor_system_test_helpers"

class TailwindFormsTest < ApplicationSystemTestCase
  include EditorSystemTestHelpers

  setup { sign_in users(:sean_eshbaugh) }

  test "mobile forms fit the viewport and checkboxes work with the keyboard" do
    original_size = page.current_window.size

    page.current_window.resize_to(390, 844)

    visit new_admin_page_path

    assert_selector "#page_body-editor.ace_editor"

    title = find_field("Title")

    assert title.evaluate_script("this.getBoundingClientRect().width > 200")
    assert title.evaluate_script("this.getBoundingClientRect().right <= window.innerWidth")
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")

    checkbox = find_field("page_visible")
    initially_checked = checkbox.checked?

    checkbox.send_keys :space

    assert_equal !initially_checked, checkbox.checked?
    assert_selector "#page_visible:focus"
  ensure
    page.current_window.resize_to(*original_size) if original_size
  end

  test "flash messages dismiss from their own control after Turbo navigation" do
    visit new_admin_page_path

    fill_in "Title", with: "Flash controller check"
    fill_in_ace "page_body", with: "<p>Flash test.</p>"

    click_button "Submit"

    saved = Page.find_by!(title: "Flash controller check")

    assert_current_path admin_page_path(saved)
    assert_selector ".flash-message"

    find_button("Dismiss message").send_keys :enter

    assert_no_selector ".flash-message"

    click_link "Edit"

    assert_selector "#page_body-editor.ace_editor"

    fill_in "Title", with: ""

    click_button "Submit"

    assert_selector ".flash-message[role=alert]", text: "Title can't be blank"

    click_button "Dismiss message"

    assert_no_selector ".flash-message"

    within ".main-header-nav" do
      click_link "Pages"
    end

    assert_link "New Page"

    page.go_back

    assert_selector "#page_body-editor.ace_editor"
    assert_no_selector ".flash-message"
  end
end
