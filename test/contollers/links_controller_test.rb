# frozen_string_literal: true

require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  test 'should get links index' do
    get links_url

    assert_response :ok
  end

  test 'should show a year of links within valid year range' do
    get links_url(year: '2021')

    assert_response :ok
  end

  test 'should not show a year of links outside valid year range' do
    assert_raise(ActionController::RoutingError) do
      get links_url(year: '2020')
    end
  end
end
