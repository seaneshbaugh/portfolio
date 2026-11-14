# frozen_string_literal: true

require "test_helper"

class QueryEfficiencyTest < ActionDispatch::IntegrationTest
  setup do
    attach_images_to_pictures!
    @sequence = 0
    add_records(1)
  end

  test "public post tags use a bounded number of queries including tagged listings" do
    assert_bounded_queries(root_path, %w[taggings tags users])
    assert_bounded_queries(root_path(tag: "query-public"), %w[taggings tags users])
    assert_select ".post-tags", text: /query-public/
    assert_select ".post-tags", text: /query-owned/, count: 0
  end

  test "admin authors and user roles do not query per row" do
    sign_in users(:sean_eshbaugh)

    assert_bounded_queries(admin_posts_path, %w[users])
    assert_bounded_queries(admin_users_path, %w[roles users_roles])
    assert_select "td.user-roles", text: "User", minimum: 5
  end

  test "picture HTML and JSON collections preload image attachments" do
    sign_in users(:sean_eshbaugh)

    [ admin_pictures_path, admin_pictures_path(format: :json), api_v1_pictures_path ].each do |path|
      assert_bounded_queries(path, %w[active_storage_attachments active_storage_blobs])
    end
  end

  test "link month and tag listings preload their tags" do
    assert_bounded_queries("/links/2021/2", %w[taggings tags])
    assert_bounded_queries(links_path(tag: "query-public"), %w[taggings tags])
    assert_select ".tags", text: /query-public/, minimum: 5
  end

  test "gallery covers are batched without loading every membership" do
    assert_bounded_queries(pictures_path, %w[gallery_pictures pictures active_storage_attachments active_storage_blobs])

    galleries = Gallery.where("name LIKE ?", "Query gallery %").preload(cover_gallery_picture: { picture: { image_attachment: :blob } }).to_a
    sql = record_queries do
      galleries.each do |gallery|
        assert_equal pictures(:cowboy).id, gallery.featured_or_first_picture.id
        assert gallery.featured_or_first_picture.image.attached?
      end
    end

    assert_empty sql
    assert galleries.all? { |gallery| !gallery.association(:gallery_pictures).loaded? }
  end

  test "admin gallery thumbnails preload attachments for all memberships" do
    sign_in users(:sean_eshbaugh)

    gallery = galleries(:salt_plains)

    assert_bounded_queries(edit_admin_gallery_path(gallery), %w[active_storage_attachments active_storage_blobs]) do
      add_records(4)

      pictures = Picture.where("title LIKE ?", "Query picture %")

      pictures.each do |picture|
        GalleryPicture.create!(gallery: gallery, picture: picture, visible: true, featured: false, order: 2)
      end
    end

    assert_select ".gallery-picture img", minimum: 3
  end

  private

  def assert_bounded_queries(path, tables)
    get path # Warm up route/template/schema caches outside the measurement.

    assert_response :ok

    before = record_queries { get path }

    assert_response :ok

    block_given? ? yield : add_records(4)

    after = record_queries { get path }

    assert_response :ok

    tables.each do |table|
      pattern = /\b(?:FROM|JOIN) "#{Regexp.escape(table)}"/
      initial_count = before.count { |sql| sql.match?(pattern) }
      final_count = after.count { |sql| sql.match?(pattern) }

      assert_operator final_count, :<=, initial_count + 1, "#{path}: #{table} queries grew from #{initial_count} to #{final_count}\n#{after.join("\n")}"
    end
  end

  def record_queries
    ActiveRecord::Base.connection_pool.clear_query_cache

    queries = []

    subscriber = ->(event) do
      payload = event.payload

      queries << payload[:sql] if !payload[:cached] && payload[:name] != "SCHEMA" && payload[:sql].match?(/\ASELECT/i)
    end

    ActiveRecord::Base.uncached do
      ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") { yield }
    end

    queries
  end

  def add_records(count)
    count.times do
      @sequence += 1
      suffix = @sequence.to_s
      user = duplicate(users(:casie_clark), email: "query-#{suffix}@example.com", slug: "query-user-#{suffix}")

      user.add_role(:user)

      post = duplicate(posts(:first_post), title: "Query post #{suffix}", slug: "query-post-#{suffix}", user_id: user.id)
      post.tag_list = "query-public"

      post.save!(validate: false)

      ActsAsTaggableOn::Tagging.create!(taggable: post, tagger: user, context: "tags", tag: ActsAsTaggableOn::Tag.find_or_create_by!(name: "query-owned"))

      link = duplicate(links(:seaneshbaugh), text: "Query link #{suffix}")
      link.tag_list = "query-public"

      link.save!(validate: false)

      picture = duplicate(pictures(:conney), title: "Query picture #{suffix}", slug: "query-picture-#{suffix}")

      picture.image.attach(pictures(:conney).image.blob)

      gallery = Gallery.create!(name: "Query gallery #{suffix}", visible: true, order: 0)

      # Hidden featured never wins; visible featured beats the earlier first picture.
      [ [ picture, false, true ], [ pictures(:conney), true, false ], [ pictures(:cowboy), true, true ] ].each_with_index do |(image, visible, featured), index|
        GalleryPicture.create!(gallery: gallery, picture: image, visible: visible, featured: featured, order: index)
      end
    end
  end

  def duplicate(record, attributes)
    record.dup.tap do |copy|
      copy.assign_attributes(attributes)

      copy.save!(validate: false)
    end
  end
end
