# frozen_string_literal: true

require "test_helper"

class SlugNormalizationTest < ActiveSupport::TestCase
  class Normalizable
    include SlugNormalization
  end

  test "normalization cleans markup and entities and applies the site's punctuation rules" do
    normalizer = Normalizable.new
    examples = {
      '<strong>Sean\'s</strong> &amp; "Friends"' => "seans-and-friends",
      "AT&amp;T &amp; R&amp;D" => "att-and-rd",
      "Sean&#39;s &quot;Résumé&quot;" => "seans-resume",
      "  Café   &amp;   résumé  " => "cafe-and-resume",
      nil => "",
      123 => "123"
    }

    examples.each do |input, expected|
      assert_equal expected, normalizer.normalize_friendly_id(input)
    end
  end

  test "every FriendlyId model uses the application normalizer" do
    [ Page, Post, User, Gallery, Picture ].each do |model|
      assert_equal "seans-and-friends", model.new.normalize_friendly_id('<strong>Sean\'s</strong> &amp; "Friends"'), model.name
    end
  end

  test "saved CMS records and users generate and resolve normalized slugs" do
    title = '<strong>Sean\'s</strong> &amp; "Friends"'
    records = [
      Page.create!(title: title, body: "<p>Page content.</p>"),
      Post.create!(user: users(:sean_eshbaugh), title: title, body: "<p>Post content.</p>"),
      Gallery.create!(name: title, order: 0),
      User.create!(first_name: "Sean's", last_name: '& "Friends"', email: "normalized-slug@example.test", password: "normalizer-test-password")
    ]

    records.each do |record|
      assert_equal "seans-and-friends", record.reload.slug, record.class.name
      assert_equal record.id, record.class.friendly.find("seans-and-friends").id
    end
  end

  test "renaming a record uses the custom normalizer for its new slug" do
    page = pages(:about)
    page.update!(title: '"Café" &amp; Notes')

    assert_equal "cafe-and-notes", page.reload.slug
    assert_equal page.id, Page.friendly.find("cafe-and-notes").id
  end

  test "existing slugs survive unrelated edits without being regenerated" do
    page = pages(:about)
    page.update_columns(title: "Sean's & Friends", slug: "sean-s-friends")
    page.reload.update!(body: "<p>Updated without renaming.</p>")

    assert_equal "sean-s-friends", page.reload.slug
    assert_equal page.id, Page.friendly.find("sean-s-friends").id
  end
end
