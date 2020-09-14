# frozen_string_literal: true

require 'test_helper'

class AdminFormBuilderTest < ActionView::TestCase
  test 'ace_editor renders a container div with a label, editor div, and textarea' do
    post = posts(:first_post)

    builder = AdminFormBuilder.new(:post, post, self, {})

    ace_editor = builder.ace_editor(:body)

    expected = <<~HTML.gsub(/\n[[:space:]]*</, '<').strip
      <div class=\"ace-editor-field input-field\">
        <label for=\"post_body\">Body</label>
        <div id=\"post_body-editor\" class=\"ace-editor\" data-mode=\"text\" data-theme=\"github\"></div>
        <textarea class=\"value\" name=\"post[body]\" id=\"post_body\">\n&lt;p&gt;My first post.&lt;/p&gt;</textarea>
      </div>
    HTML

    assert_dom_equal(expected, ace_editor)
  end

  test 'picture_inserter renders a div' do
    post = posts(:first_post)

    builder = AdminFormBuilder.new(:post, post, self, {})

    picture_inserter = builder.picture_inserter(:body)

    expected = '<div class="picture-inserter" data-buttonclassname="btn btn-flat waves-effect waves-light blue lighten-3" data-buttontext="Insert Picture" data-target="post_body-editor"></div>'

    assert_dom_equal(expected, picture_inserter)
  end

  test 'picture_inserter renders a div using block content as text' do
    post = posts(:first_post)

    builder = AdminFormBuilder.new(:post, post, self, {})

    picture_inserter = builder.picture_inserter(:body) do
      'TESTING 1 2 3'
    end

    expected = '<div class="picture-inserter" data-buttonclassname="btn btn-flat waves-effect waves-light blue lighten-3" data-buttontext="TESTING 1 2 3" data-target="post_body-editor"></div>'

    assert_dom_equal(expected, picture_inserter)
  end
end
