# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class TagsControllerTest < ActionDispatch::IntegrationTest
      test "index returns plain tag names including special characters without pagination" do
        names = [ "C++", "Design & art", "日本語", *26.times.map { |index| "API tag #{index}" } ]

        names.each { |name| ActsAsTaggableOn::Tag.create!(name: name) }

        get api_v1_tags_path

        assert_response :ok
        assert_equal "application/json", response.media_type
        assert_kind_of Array, response.parsed_body
        assert_equal names.sort, response.parsed_body.sort
      end

      test "empty index is an array" do
        ActsAsTaggableOn::Tag.destroy_all

        get api_v1_tags_path

        assert_response :ok
        assert_equal [], response.parsed_body
      end
    end
  end
end
