# frozen_string_literal: true

require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  test 'should get posts index' do
    get :index

    assert_response :ok
  end

  test 'should show a post' do
    post = posts(:first_post)

    get :show, params: { id: post }

    assert_response :ok
  end

  test 'should not show a post that does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 'does-not-exist' }
    end
  end
end
