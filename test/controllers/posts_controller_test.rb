# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get posts index" do
    get root_url

    assert_response :ok
  end

  test "should show a post" do
    post = posts(:first_post)

    get post_url(post)

    assert_response :ok
  end

  test "should not show a post that does not exist" do
    get post_url(id: "does-not-exist")

    assert_response :not_found
  end

  test "read more markers truncate at the beginning middle and end and never truncate detail" do
    post = posts(:first_post)

    [ [ "", "<p>After marker</p>" ], [ "<p>Before marker</p>", "<p>After marker</p>" ], [ "<p>Before marker</p>", "" ] ].each do |before, after|
      post.update_column(:body, "#{before}<!--more-->#{after}")

      get root_path

      assert_response :ok
      assert_select "#post-#{post.slug} .body-content.truncated", text: Nokogiri::HTML.fragment(before).text
      assert_select "#post-#{post.slug} .read-more a[href=?]", post_path(post)

      get post_path(post)

      assert_response :ok
      assert_select ".body-content", text: Nokogiri::HTML.fragment(before + after).text
    end

    post.update_column(:body, "<p>Without a marker</p>")

    get root_path

    assert_response :ok
    assert_select "#post-#{post.slug} .body-content", text: "Without a marker"
    assert_select "#post-#{post.slug} .read-more", count: 0
  end
end
