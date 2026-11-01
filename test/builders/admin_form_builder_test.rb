# frozen_string_literal: true

require "test_helper"

class AdminFormBuilderTest < ActionView::TestCase
  test "ace_editor renders a container div with a label, editor div, and textarea" do
    post = posts(:first_post)

    builder = AdminFormBuilder.new(:post, post, self, {})

    ace_editor = builder.ace_editor(:body)

    expected = <<~HTML.gsub(/\n[[:space:]]*</, "<").strip
      <div class=\"ace-editor-field input-field\" data-controller=\"ace-editor\" data-ace-editor-mode-value=\"text\" data-ace-editor-theme-value=\"github\">
        <label for=\"post_body\">Body</label>
        <div id=\"post_body-editor\" class=\"ace-editor\" data-ace-editor-target=\"editor\"></div>
        <textarea class=\"value\" data-ace-editor-target=\"input\" name=\"post[body]\" id=\"post_body\">\n&lt;p&gt;My first post.&lt;/p&gt;</textarea>
      </div>
    HTML

    assert_dom_equal(expected, ace_editor)
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
