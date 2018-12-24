# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class TagsControllerTest < ActionDispatch::IntegrationTest
      test 'should get tags index' do
        get api_v1_tags_url

        assert_response :ok
      end
    end
  end
end
