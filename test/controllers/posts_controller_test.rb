# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "RSS contains published posts in newest-first order with usable dates and links" do
    first = posts(:first_post)
    first.update!(title: "Ruby & Rails <notes>", body: "<p>Ruby &amp; Rails <strong>notes</strong>.</p>", created_at: Time.utc(2026, 3, 2, 11, 12, 13))

    second = posts(:second_post)
    second.update!(created_at: Time.utc(2026, 4, 3, 12, 13, 14))

    Post.create!(user: users(:sean_eshbaugh), title: "Hidden feed item", body: "<p>Do not publish this draft.</p>", visible: false, created_at: Time.utc(2026, 5, 4, 13, 14, 15))

    get "/posts.rss"

    assert_response :ok
    assert_equal "application/rss+xml", response.media_type

    document = Nokogiri::XML(response.body) { |config| config.strict.nonet }
    channel = document.at_xpath('/rss[@version="2.0"]/channel')

    assert channel
    assert_equal "seaneshbaugh.com", channel.at_xpath("title").text
    assert_equal root_url, channel.at_xpath("link").text

    items = channel.xpath("item")

    assert_equal [ post_url(second), post_url(first) ], items.map { |item| item.at_xpath("link").text }

    [ second, first ].zip(items).each do |post, item|
      assert_equal post.title, item.at_xpath("title").text
      assert_equal post.body, item.at_xpath("description").text
      assert_equal post_url(post), item.at_xpath("guid").text
      assert_equal post.created_at.to_i, Time.rfc2822(item.at_xpath("pubDate").text).to_i
    end
  end

  test "RSS remains a valid feed when there are no posts" do
    Post.destroy_all

    get "/posts.rss"

    assert_response :ok
    assert_equal "application/rss+xml", response.media_type

    document = Nokogiri::XML(response.body) { |config| config.strict.nonet }
    channel = document.at_xpath('/rss[@version="2.0"]/channel')

    assert channel
    assert_equal "seaneshbaugh.com", channel.at_xpath("title").text
    assert_equal root_url, channel.at_xpath("link").text
    assert_empty channel.xpath("item")
  end

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
