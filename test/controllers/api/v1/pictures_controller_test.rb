# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class PicturesControllerTest < ActionDispatch::IntegrationTest
      setup { attach_images_to_pictures! }

      test "index returns picture documents and paginates without overlaps" do
        source = pictures(:conney)
        source.update_column(:created_at, 2.days.ago)

        pictures(:cowboy).update_column(:created_at, 1.day.ago)

        added = 26.times.map do |index|
          Picture.create!(title: "API image #{index}", image: source.image.blob, created_at: index.minutes.from_now)
        end

        get api_v1_pictures_path

        assert_response :ok
        assert_equal "application/json", response.media_type

        first = response.parsed_body

        assert_kind_of Array, first
        assert_equal 25, first.length
        assert_picture_document first.first, Picture.find(first.first.fetch("data").fetch("id"))

        get api_v1_pictures_path, params: { page: 2 }

        assert_response :ok

        second = response.parsed_body

        assert_equal 3, second.length
        assert_picture_document second.first, Picture.find(second.first.fetch("data").fetch("id"))

        ids = (first + second).map { |item| item.fetch("data").fetch("id").to_i }

        assert_equal added.reverse.map(&:id) + [ pictures(:cowboy).id, source.id ], ids
        assert_equal ids.uniq, ids

        get api_v1_pictures_path, params: { page: 3 }

        assert_response :ok
        assert_equal [], response.parsed_body
      end

      test "detail exposes public metadata and usable signed read URLs" do
        record = pictures(:conney)
        record.update!(title: "Conney & friends", alt_text: 'A "corgi" & friends', caption: "Public caption")

        get api_v1_picture_path(record)

        assert_response :ok
        assert_equal "application/json", response.media_type

        document = response.parsed_body

        assert_picture_document document, record

        get document.fetch("data").fetch("attributes").fetch("original_image_path")

        assert_response :redirect
        assert_includes URI(response.location).path, "/rails/active_storage/disk/"
      end

      test "empty index is an array and missing detail returns 404" do
        Picture.destroy_all

        get api_v1_pictures_path

        assert_response :ok
        assert_equal [], response.parsed_body

        get api_v1_picture_path("does-not-exist"), as: :json

        assert_response :not_found
      end

      private

      def assert_picture_document(document, record)
        assert_equal [ "data" ], document.keys

        data = document.fetch("data")

        assert_equal %w[attributes id type], data.keys.sort
        assert_equal record.id.to_s, data.fetch("id")
        assert_equal "picture", data.fetch("type")

        attributes = data.fetch("attributes")
        expected_fields = %w[alt_text caption created_at medium_image_path medium_image_url original_image_path original_image_url slug thumbnail_image_path thumbnail_image_url title updated_at]

        assert_equal expected_fields, attributes.keys.sort
        assert_equal record.attributes.slice("slug", "title", "alt_text", "caption"), attributes.slice("slug", "title", "alt_text", "caption")

        %w[created_at updated_at].each do |field|
          assert_equal record.public_send(field).to_i, Time.iso8601(attributes.fetch(field)).to_i
        end

        expected_paths = {
          "original" => rails_blob_path(record.image, only_path: true),
          "medium" => rails_representation_path(record.image.variant(resize_to_limit: [ 500, nil ]), only_path: true),
          "thumbnail" => rails_representation_path(record.image.variant(resize_to_limit: [ 100, nil ]), only_path: true)
        }

        expected_paths.each do |size, path|
          assert_equal path, attributes.fetch("#{size}_image_path")

          url = URI(attributes.fetch("#{size}_image_url"))

          assert_includes %w[http https], url.scheme
          assert url.host.present?
          assert_equal path, url.path
        end
      end
    end
  end
end
