# frozen_string_literal: true

require "test_helper"
require_relative "../../support/admin_access_assertions"

module Admin
  class PicturesControllerTest < ActionDispatch::IntegrationTest
    include AdminAccessAssertions

    setup do
      attach_images_to_pictures!

      sign_in users(:sean_eshbaugh)
    end

    test "guests cannot create update or destroy pictures" do
      prepare_admin_access_actor

      record = pictures(:conney)
      attributes = { title: "Unauthorized picture", image: pictures(:conney).image.blob.signed_id }

      [
        [ :post, admin_pictures_path, { picture: attributes } ],
        [ :patch, admin_picture_path(record), { picture: attributes } ],
        [ :delete, admin_picture_path(record), {} ]
      ].each do |method, path, parameters|
        assert_admin_data_unchanged(record) do
          public_send(method, path, params: parameters)
        end

        assert_redirected_to new_user_session_path
      end
    end

    test "non-admin users cannot create update or destroy pictures" do
      prepare_admin_access_actor(users(:casie_clark))

      record = pictures(:conney)
      attributes = { title: "Unauthorized picture", image: pictures(:conney).image.blob.signed_id }

      [
        [ :post, admin_pictures_path, { picture: attributes } ],
        [ :patch, admin_picture_path(record), { picture: attributes } ],
        [ :delete, admin_picture_path(record), {} ]
      ].each do |method, path, parameters|
        assert_admin_data_unchanged(record) do
          public_send(method, path, params: parameters)
        end

        assert_response :forbidden
      end
    end

    test "should get pictures index" do
      get admin_pictures_url

      assert_response :ok
    end

    test "should show a picture" do
      picture = pictures(:conney)

      get admin_picture_url(picture)

      assert_response :ok
    end

    test "should not show a picture that does not exist" do
      get admin_picture_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "should get a new picture" do
      get new_admin_picture_url

      assert_response :ok
    end

    test "should get a picture to edit" do
      picture = pictures(:cowboy)

      get edit_admin_picture_url(picture)

      assert_response :ok
    end

    test "should not get a picture that does not exist to edit" do
      get edit_admin_picture_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "should create a picture" do
      assert_difference("Picture.count", 1) do
        post admin_pictures_url, params: { picture: { title: "New Picture", body: "Testing 1 2 3", image: fixture_file_upload("conney-the-corgi.jpg", "image/jpeg", true) } }
      end

      assert_response :see_other

      assert_redirected_to admin_picture_path(Picture.chronological.last)
    end

    test "XHR picture creation returns an escaped row with working actions" do
      post admin_pictures_url,
        params: { picture: { title: "<b>Uploaded photograph</b>", image: fixture_file_upload("conney-the-corgi.jpg", "image/jpeg", true) } },
        headers: { "Accept" => "text/html", "X-Requested-With" => "XMLHttpRequest" }

      picture = Picture.chronological.last

      assert_response :ok
      assert_equal "text/html", response.media_type

      # A standalone table row needs table context when parsed as an HTML document.
      fragment = Nokogiri::HTML.fragment("<table>#{response.body}</table>")

      assert_select fragment, "tr.picture", count: 1 do
        assert_select ".picture-title a[href=?]", admin_picture_path(picture), text: "<b>Uploaded photograph</b>"
        assert_select ".picture-title b", count: 0
        assert_select ".edit a[href=?]", edit_admin_picture_path(picture)
        assert_select ".delete a[data-turbo-method=delete][href=?]", admin_picture_path(picture)
      end
    end

    test "XHR picture validation returns JSON errors" do
      assert_no_difference("Picture.count") do
        post admin_pictures_url, params: { picture: { title: "Missing image" } },
          headers: { "Accept" => "text/html", "X-Requested-With" => "XMLHttpRequest" }
      end

      assert_response :unprocessable_entity
      assert_equal "application/json", response.media_type
      assert response.parsed_body.fetch("errors").any? { |error| error.fetch("title").include?("Image") }
    end

    test "JSON picture creation retains the serializer response" do
      post admin_pictures_url,
        params: { picture: { image: fixture_file_upload("conney-the-corgi.jpg", "image/jpeg", true) } },
        headers: { "Accept" => "application/json" }

      assert_response :ok
      assert_equal "application/json", response.media_type
      assert_equal Picture.chronological.last.id.to_s, response.parsed_body.dig("data", "id")
    end

    test "should not create an invalid picture" do
      assert_no_difference("Picture.count") do
        post admin_pictures_url, params: { picture: { title: "Image Intentionally Left Blank" } }
      end

      assert_response :unprocessable_entity
    end

    test "should update a picture" do
      picture = pictures(:conney)

      patch admin_picture_url(picture), params: { picture: { title: "Updated Picture" } }

      picture.reload

      assert_equal("Updated Picture", picture.title)

      assert_response :see_other

      assert_redirected_to edit_admin_picture_path(picture)

      assert_equal(I18n.t("admin.pictures.update.success"), flash[:success])
    end

    test "should not update a picture with invalid data" do
      picture = pictures(:cowboy)

      patch admin_picture_url(picture), params: { picture: { title: "A" * 65536 } }

      assert_response :unprocessable_entity
    end

    test "should not update a picture that does not exist" do
      patch admin_picture_url(id: "does-not-exist"), params: { picture: { title: "Does Not Exist", body: "Picture intentionally left blank." } }

      assert_response :not_found
    end

    test "should destroy a picture" do
      picture = pictures(:conney)

      assert_difference("Picture.count", -1) do
        delete admin_picture_url(picture)
      end

      assert_response :see_other

      assert_redirected_to admin_pictures_path
    end

    test "should not destroy a picture that does not exist" do
      delete admin_picture_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "picture JSON pages have stable ordering and advertise the next page" do
      source = pictures(:conney)

      timestamp = Time.current.change(usec: 0)

      26.times do |index|
        picture = Picture.create!(title: "Paging picture #{index}", image: source.image.blob, created_at: timestamp)

        assert picture.persisted?
      end

      get admin_pictures_path(format: :json)

      assert_response :ok

      first_page = response.parsed_body.map { |picture| picture.fetch("data").fetch("id").to_i }

      assert_equal 25, first_page.length
      assert_equal "2", response.headers["X-Next-Page"]

      get admin_pictures_path(format: :json), params: { page: 2 }

      assert_response :ok

      second_page = response.parsed_body.map { |picture| picture.fetch("data").fetch("id").to_i }

      assert_equal "", response.headers["X-Next-Page"]
      assert_equal Picture.reverse_chronological.order(id: :desc).pluck(:id), first_page + second_page
      assert_empty first_page & second_page
    end
  end
end
