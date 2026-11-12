# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should show a page" do
    page = pages(:about)

    get page_url(page)

    assert_response :ok
  end

  test "should not show a page that does not exist" do
    get page_url(id: "does-not-exist")

    assert_response :not_found
  end
end
