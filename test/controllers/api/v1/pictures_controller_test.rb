# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class PicturesControllerTest < ActionDispatch::IntegrationTest
      setup do
        attach_images_to_pictures!
      end

      test "should get pictures index" do
        get api_v1_pictures_url

        assert_response :ok
      end

      test "should show a picture" do
        picture = pictures(:conney)

        get api_v1_picture_url(picture)

        assert_response :ok

        assert_equal(PictureSerializer.new(picture).to_json, response.body)
      end

      test "should not show a picture that does not exist" do
        get api_v1_picture_url(id: "does-not-exist")

        assert_response :not_found
      end
    end
  end
end
