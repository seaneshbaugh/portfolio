# frozen_string_literal: true

require 'test_helper'

class Admin::PostsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:sean_eshbaugh)
  end

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
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 'does-not-exist' }
    end
  end

  test 'should get a new post' do
    get :new

    assert_response :ok
  end

  test 'should get a post to edit' do
    post = posts(:first_post)

    get :edit, params: { id: post }

    assert_response :ok
  end

  test 'should not get a post that does not exist to edit' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, params: { id: 'does-not-exist' }
    end
  end

  test 'should create a post' do
    assert_difference('Post.count', 1) do
      post :create, params: { post: { title: 'New Post', body: 'Testing 1 2 3' } }
    end

    assert_response :see_other

    assert_redirected_to admin_post_path(Post.chronological.last)
  end

  test 'should not create an invalid post' do
    assert_no_difference('Post.count') do
      post :create, params: { post: { title: '' } }
    end

    assert_response :unprocessable_entity
  end

  test 'should update a post' do
    post = posts(:first_post)

    patch :update, params: { id: post, post: { title: 'Updated Post' } }

    post.reload

    assert post.title == 'Updated Post'

    assert_response :see_other

    assert_redirected_to edit_admin_post_path(post)

    assert_equal I18n.t('admin.posts.update.success'), flash[:success]
  end

  test 'should not update a post with invalid data' do
    post = posts(:first_post)

    patch :update, params: { id: post, post: { title: '' } }

    assert_response :unprocessable_entity
  end

  test 'should not update a post that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      patch :update, params: { id: 'does-not-exist', post: { title: 'Does Not Exist', body: 'I have nothing to say.' } }
    end
  end

  test 'should destroy a post' do
    post = posts(:first_post)

    assert_difference('Post.count', -1) do
      delete :destroy, params: { id: post }
    end

    assert_response :see_other

    assert_redirected_to admin_posts_path
  end

  test 'should not destroy a post that does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete :destroy, params: { id: 'does-not-exist' }
    end
  end
end
