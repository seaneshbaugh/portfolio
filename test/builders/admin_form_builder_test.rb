# frozen_string_literal: true

require "test_helper"

class AdminFormBuilderTest < ActionView::TestCase
  test "ace_editor renders a container div with a label, editor div, and textarea" do
    post = posts(:first_post)
    builder = AdminFormBuilder.new(:post, post, self, {})
    ace_editor = builder.ace_editor(:body)
    fragment = Nokogiri::HTML.fragment(ace_editor)
    field = fragment.at_css("[data-controller=ace-editor]")

    assert_equal "text", field["data-ace-editor-mode-value"]
    assert_equal "github", field["data-ace-editor-theme-value"]
    assert_equal "post_body", field.at_css("label")["for"]
    assert_equal "post_body-editor", field.at_css("[data-ace-editor-target=editor]")["id"]

    textarea = field.at_css("textarea[data-ace-editor-target=input]")

    assert_equal "post[body]", textarea["name"]
    assert_equal post.body, textarea.text.strip
    assert textarea.key?("hidden")
  end

  test "picture_inserter renders a selector targeting the editor" do
    builder = AdminFormBuilder.new(:post, posts(:first_post), self, {})
    selector = Nokogiri::HTML.fragment(builder.picture_inserter(:body)).at_css(".picture-inserter")

    assert_equal "post_body-editor", selector["data-target"]
    assert_equal "picture-selector", selector["data-controller"]
    assert_equal "false", selector["data-picture-selector-ready-value"]
    assert selector.at_css("button").key?("disabled")
    assert_equal admin_pictures_path(format: :json), selector["data-picture-selector-url-value"]
    assert_equal "Insert Picture", selector.at_css("button").text
    assert_equal "button", selector.at_css("button")["type"]
    assert_equal "dialog", selector.at_css(".picture-selector-modal")["role"]
  end

  test "picture_inserter uses block content as the button text" do
    builder = AdminFormBuilder.new(:post, posts(:first_post), self, {})
    selector = builder.picture_inserter(:body) { "TESTING 1 2 3" }

    assert_equal "TESTING 1 2 3", Nokogiri::HTML.fragment(selector).at_css("button").text
  end
end
