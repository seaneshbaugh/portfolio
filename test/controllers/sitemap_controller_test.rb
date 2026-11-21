# frozen_string_literal: true

require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  SITEMAP_NAMESPACE = { "s" => "http://www.sitemaps.org/schemas/sitemap/0.9" }.freeze

  test "sitemap lists published content in the standard XML namespace" do
    Page.update_all(visible: false)
    Post.update_all(visible: false)

    about = pages(:about)
    about.update!(visible: true, updated_at: Time.utc(2026, 11, 10, 11, 12, 13))

    unlisted = pages(:resume)
    unlisted.update!(visible: true, show_in_menu: false, updated_at: Time.utc(2026, 10, 7, 12, 13, 14))

    post = posts(:first_post)
    post.update!(visible: true, updated_at: Time.utc(2026, 9, 10, 13, 14, 15))

    gallery = galleries(:salt_plains)
    gallery.update!(visible: true, updated_at: Time.utc(2026, 8, 9, 14, 15, 16))

    Gallery.create!(name: "Hidden sitemap gallery", visible: false, order: 1)

    get sitemap_path

    assert_response :ok
    assert_equal "application/xml", response.media_type

    entries = parsed_sitemap_entries

    assert_equal [ root_url, page_url(about), page_url(unlisted), post_url(post), pictures_url, picture_url(gallery) ].sort, entries.keys.sort

    [ about, unlisted, post, gallery ].each do |record|
      url = case record
      when Page then page_url(record)
      when Post then post_url(record)
      when Gallery then picture_url(record)
      end

      assert_equal record.updated_at.to_i, entries.fetch(url).to_i
    end
  end

  test "sitemap keeps the homepage and gallery index when there is no content" do
    Page.destroy_all
    Post.destroy_all
    Gallery.destroy_all

    get sitemap_path

    assert_response :ok
    assert_equal "application/xml", response.media_type
    assert_equal [ root_url, pictures_url ].sort, parsed_sitemap_entries.keys.sort
  end

  private

  def parsed_sitemap_entries
    document = Nokogiri::XML(response.body) { |config| config.strict.nonet }

    assert_equal "urlset", document.root.name
    assert_equal SITEMAP_NAMESPACE.fetch("s"), document.root.namespace.href

    entries = document.xpath("/s:urlset/s:url", SITEMAP_NAMESPACE)

    locations = entries.map do |entry|
      assert_equal 1, entry.xpath("s:loc", SITEMAP_NAMESPACE).length
      assert_equal 1, entry.xpath("s:lastmod", SITEMAP_NAMESPACE).length

      [ entry.at_xpath("s:loc", SITEMAP_NAMESPACE).text, Time.iso8601(entry.at_xpath("s:lastmod", SITEMAP_NAMESPACE).text) ]
    end

    assert_equal locations.map(&:first).uniq, locations.map(&:first)

    locations.to_h
  end
end
