# frozen_string_literal: true

require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test 'should get posts index' do
    get root_url

    assert_response :ok
  end

  test 'should show a post' do
    post = posts(:first_post)

    get post_url(post)

    assert_response :ok
  end

  test 'should not show a post that does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) do
      get post_url(id: 'does-not-exist')
    end
  end
end
