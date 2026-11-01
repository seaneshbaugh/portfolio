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
