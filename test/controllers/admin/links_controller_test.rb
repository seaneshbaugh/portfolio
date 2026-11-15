# frozen_string_literal: true

require "test_helper"
require_relative "../../support/admin_access_assertions"

module Admin
  class LinksControllerTest < ActionDispatch::IntegrationTest
    include AdminAccessAssertions

    setup do
      sign_in users(:sean_eshbaugh)
    end

    test "guests cannot create update or destroy links" do
      prepare_admin_access_actor

      record = links(:seaneshbaugh)
      attributes = { text: "Unauthorized link", url: "https://example.com/unauthorized", published_at: "2026-11-15", visible: true }

      [
        [ :post, admin_links_path, { link: attributes } ],
        [ :patch, admin_link_path(record), { link: attributes } ],
        [ :delete, admin_link_path(record), {} ]
      ].each do |method, path, parameters|
        assert_admin_data_unchanged(record) do
          public_send(method, path, params: parameters)
        end

        assert_redirected_to new_user_session_path
      end
    end

    test "non-admin users cannot create update or destroy links" do
      prepare_admin_access_actor(users(:casie_clark))
      record = links(:seaneshbaugh)

      attributes = { text: "Unauthorized link", url: "https://example.com/unauthorized", published_at: "2026-11-15", visible: true }

      [
        [ :post, admin_links_path, { link: attributes } ],
        [ :patch, admin_link_path(record), { link: attributes } ],
        [ :delete, admin_link_path(record), {} ]
      ].each do |method, path, parameters|
        assert_admin_data_unchanged(record) do
          public_send(method, path, params: parameters)
        end

        assert_response :forbidden
      end
    end

    test "should get links index" do
      get admin_links_url

      assert_response :ok
    end

    test "should show a link" do
      link = links(:seaneshbaugh)

      get admin_link_url(link)

      assert_response :ok
    end

    test "should not show a link that does not exist" do
      get admin_link_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "should get a new link" do
      get new_admin_link_url

      assert_response :ok
    end

    test "should get a link to edit" do
      link = links(:seaneshbaugh)

      get edit_admin_link_url(link)

      assert_response :ok
    end

    test "should not get a link that does not exist to edit" do
      get edit_admin_link_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "should create a link" do
      assert_difference("Link.count", 1) do
        post admin_links_url, params: { link: { text: "test", url: "http://test.com/", description: "this is a test", published_at: Time.zone.now.strftime("%Y-%m-%d"), visible: true } }
      end

      assert_response :see_other

      assert_redirected_to admin_link_path(Link.chronological.last)
    end

    test "should not create an invalid link" do
      assert_no_difference("Link.count") do
        post admin_links_url, params: { link: { text: "" } }
      end

      assert_response :unprocessable_entity
    end

    test "should update a link" do
      link = links(:seaneshbaugh)

      patch admin_link_url(link), params: { link: { text: "Updated Link" } }

      link.reload

      assert_equal("Updated Link", link.text)

      assert_response :see_other

      assert_redirected_to edit_admin_link_path(link)

      assert_equal(I18n.t("admin.links.update.success"), flash[:success])
    end

    test "should not update a link with invalid data" do
      link = links(:seaneshbaugh)

      patch admin_link_url(link), params: { link: { text: "" } }

      assert_response :unprocessable_entity
    end

    test "should not update a link that does not exist" do
      patch admin_link_url(id: "does-not-exist"), params: { link: { text: "Does Not Exist", body: "I have nothing to say." } }

      assert_response :not_found
    end

    test "should destroy a link" do
      link = links(:seaneshbaugh)

      assert_difference("Link.count", -1) do
        delete admin_link_url(link)
      end

      assert_response :see_other

      assert_redirected_to admin_links_path
    end

    test "should not destroy a link that does not exist" do
      delete admin_link_url(id: "does-not-exist")

      assert_response :not_found
    end

    test "blank link dates render validation errors and preserve entered values" do
      attributes = { text: "Entered link", url: "https://example.com/kept", description: "Keep this description", published_at: "", visible: true }

      assert_no_difference "Link.count" do
        post admin_links_path, params: { link: attributes }
      end

      assert_response :unprocessable_entity
      assert_select ".flash-message", text: /Published At can't be blank/
      assert_select "input[name='link[text]'][value='Entered link']"
      assert_select "input[name='link[url]'][value='https://example.com/kept']"
      assert_select "textarea[name='link[description]']", text: "Keep this description"

      link = links(:seaneshbaugh)
      original_date = link.published_at

      patch admin_link_path(link), params: { link: attributes }

      assert_response :unprocessable_entity
      assert_select "input[name='link[text]'][value='Entered link']"
      assert_equal original_date, link.reload.published_at
      assert_not_equal attributes[:text], link.text
    end
  end
end
