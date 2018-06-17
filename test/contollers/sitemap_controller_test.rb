require 'test_helper'

class SitemapControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, format: :xml

    assert_response :ok
  end
end
