require "application_system_test_case"
require_relative "../../support/editor_system_test_helpers"
require_relative "../../support/system_test_uploads"

module Admin
  class AceEditorsTest < ApplicationSystemTestCase
    include EditorSystemTestHelpers
    include SystemTestUploads

    setup do
      sign_in users(:sean_eshbaugh)
    end

    test "editors load their modes and workers and report syntax errors" do
      visit new_admin_post_path

      { body: "rhtml", style: "css", script: "javascript" }.each do |field, mode|
        assert_selector "#post_#{field}-editor.ace_editor" do |editor|
          editor.evaluate_script("this.env.editor.session.getMode().$id") == "ace/mode/#{mode}" &&
            editor.evaluate_script("this.env.editor.getTheme()") == "ace/theme/github"
        end
      end

      fill_in_ace "post_style", with: "p { color: ; }"
      fill_in_ace "post_script", with: "const = ;"

      %w[style script].each do |field|
        assert_selector "#post_#{field}-editor" do |editor|
          editor.evaluate_script("this.env.editor.session.getAnnotations().length > 0")
        end
      end
    end

    test "pictures beyond the first page can be selected in Ace and gallery forms" do
      attach_images_to_pictures!

      source = pictures(:conney)

      26.times do |index|
        Picture.create!(title: "Selector page image #{index}", image: source.image.blob, created_at: 1.minute.from_now)
      end

      visit new_admin_post_path

      click_button "Insert Picture"

      assert_selector ".picture-selector-modal-picture", count: 25

      click_button "Load more pictures"

      assert_selector ".picture-selector-modal-picture", count: 28
      assert_no_button "Load more pictures"

      find(".picture-selector-modal-picture", text: source.title).click

      assert_no_selector ".picture-selector-modal"
      assert_includes find_field("post_body", visible: :all).value, source.original_image_path

      visit new_admin_gallery_path

      click_button "Add Picture"

      assert_selector ".picture-selector-modal-picture", count: 25

      click_button "Load more pictures"

      assert_selector ".picture-selector-modal-picture", count: 28

      find(".picture-selector-modal-picture", text: source.title).click

      assert_no_selector ".picture-selector-modal"
      assert_selector ".gallery-picture input[name$='[picture_id]'][value='#{source.id}']", visible: :all

      # Reopening starts a fresh page and Escape restores focus to the opener.
      click_button "Add Picture"

      assert_selector ".picture-selector-modal-picture", count: 25

      find(".picture-selector-close-button").send_keys(:escape)

      assert_no_selector ".picture-selector-modal"
      assert_selector "button:focus", text: "Add Picture"
    end

    test "disconnect destroys the editor and reconnect preserves text without duplicate insertion" do
      attach_images_to_pictures!

      visit new_admin_post_path

      fill_in_ace "post_body", with: "<p>Keep this draft.</p>"

      page.execute_script(<<~JS)
        window.editorField = document.querySelector('#post_body-editor').closest('[data-controller="ace-editor"]');
        window.oldEditor = document.querySelector('#post_body-editor').env.editor;
        window.editorField.removeAttribute('data-controller');
      JS

      assert_button "Insert Picture", disabled: true
      assert page.evaluate_script("window.oldEditor.destroyed && window.oldEditor.session.destroyed && !window.oldEditor.session.$worker")
      assert_field "post_body", with: "<p>Keep this draft.</p>", visible: :all

      page.execute_script("window.editorField.setAttribute('data-controller', 'ace-editor')")

      assert_button "Insert Picture", disabled: false

      assert_selector "#post_body-editor.ace_editor" do |editor|
        editor.evaluate_script("this.env.editor.getValue()") == "<p>Keep this draft.</p>"
      end

      select_picture pictures(:conney)

      body = find_field("post_body", visible: :all).value

      assert_equal 1, Nokogiri::HTML.fragment(body).css("img").length
      assert_includes body, "Keep this draft."
    end
  end
end
