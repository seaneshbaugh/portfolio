# frozen_string_literal: true

require 'test_helper'

class SitemapControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get sitemap_url, as: :xml

    assert_response :ok
  end
end
