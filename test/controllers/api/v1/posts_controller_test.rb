# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class PostsControllerTest < ActionDispatch::IntegrationTest
      test "index returns published post documents without imposing pagination" do
        26.times do |index|
          Post.create!(user: users(:sean_eshbaugh), title: "API post #{index}", body: "<p>API content.</p>", visible: true)
        end

        posts(:second_post).update!(visible: false)

        get api_v1_posts_path

        assert_response :ok
        assert_equal "application/json", response.media_type

        documents = response.parsed_body

        assert_kind_of Array, documents
        assert_equal Post.published.pluck(:id).map(&:to_s).sort, documents.map { |item| item.fetch("data").fetch("id") }.sort
        assert_operator documents.length, :>, 25

        sample = documents.first

        assert_post_document sample, Post.find(sample.fetch("data").fetch("id"))
      end

      test "detail preserves CMS content and exposes only the public post fields" do
        record = posts(:first_post)
        record.update!(body: "<p>Ruby &amp; Rails <strong>notes</strong>.</p>", style: "p { color: blue; }", script: "window.apiPost = true;")

        get api_v1_post_path(record)

        assert_response :ok
        assert_equal "application/json", response.media_type
        assert_post_document response.parsed_body, record
      end

      test "empty public index is an array and hidden and missing details return 404" do
        Post.update_all(visible: false)

        get api_v1_posts_path

        assert_response :ok
        assert_equal [], response.parsed_body

        [ posts(:first_post).to_param, "does-not-exist" ].each do |id|
          get api_v1_post_path(id), as: :json

          assert_response :not_found
        end
      end

      private

      def assert_post_document(document, record)
        assert_equal [ "data" ], document.keys

        data = document.fetch("data")

        assert_equal %w[attributes id type], data.keys.sort
        assert_equal record.id.to_s, data.fetch("id")
        assert_equal "post", data.fetch("type")

        attributes = data.fetch("attributes")

        assert_equal %w[body created_at script style title updated_at], attributes.keys.sort
        assert_equal record.attributes.slice("title", "body", "style", "script"), attributes.slice("title", "body", "style", "script")

        %w[created_at updated_at].each do |field|
          assert_equal record.public_send(field).to_i, Time.iso8601(attributes.fetch(field)).to_i
        end
      end
    end
  end
end
