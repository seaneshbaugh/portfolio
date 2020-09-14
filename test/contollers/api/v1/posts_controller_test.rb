# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PostsControllerTest < ActionDispatch::IntegrationTest
      test 'should get posts index' do
        get api_v1_posts_url

        assert_response :ok
      end

      test 'should show a post' do
        post = posts(:first_post)

        get api_v1_post_url(post)

        assert_response :ok

        assert_equal(PostSerializer.new(post).to_json, response.body)
      end

      test 'should not show a post that does not exist' do
        assert_raises(ActiveRecord::RecordNotFound) do
          get api_v1_post_url(id: 'does-not-exist')
        end
      end
    end
  end
end
