# frozen_string_literal: true

require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  test "should get links index" do
    get links_url

    assert_response :ok
  end

  test "should show a year of links within valid year range" do
    get links_url(year: "2021")

    assert_response :ok
  end

  test "should not show a year of links outside valid year range" do
    get links_url(year: "2020")

    assert_response :not_found
  end

  test "link tags encode plus signs ampersands and Unicode and round trip through filtering" do
    link = links(:seaneshbaugh)
    tags = [ "C++", "Design & art", "日本語" ]

    link.update!(tag_list: tags)

    get "/links/2021/2"

    assert_response :ok

    anchors = Nokogiri::HTML(response.body).css(".tags a")

    tags.each do |tag|
      href = anchors.find { |anchor| anchor.text == tag }["href"]

      assert_equal tag, Rack::Utils.parse_nested_query(URI(href).query).fetch("tag")

      get href

      assert_response :ok
      assert_select ".links .link a[href=?]", link.url
    end
  end
end
