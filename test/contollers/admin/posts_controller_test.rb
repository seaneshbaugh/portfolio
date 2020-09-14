# frozen_string_literal: true

require 'test_helper'

module Admin
  class PostsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:sean_eshbaugh)
    end

    test 'should get posts index' do
      get admin_posts_url

      assert_response :ok
    end

    test 'should show a post' do
      post = posts(:first_post)

      get admin_post_url(post)

      assert_response :ok
    end

    test 'should not show a post that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get admin_post_url(id: 'does-not-exist')
      end
    end

    test 'should get a new post' do
      get new_admin_post_url

      assert_response :ok
    end

    test 'should get a post to edit' do
      post = posts(:first_post)

      get edit_admin_post_url(post)

      assert_response :ok
    end

    test 'should not get a post that does not exist to edit' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get edit_admin_post_url(id: 'does-not-exist')
      end
    end

    test 'should create a post' do
      assert_difference('Post.count', 1) do
        post admin_posts_url, params: { post: { title: 'New Post', body: 'Testing 1 2 3' } }
      end

      assert_response :see_other

      assert_redirected_to admin_post_path(Post.chronological.last)
    end

    test 'should not create an invalid post' do
      assert_no_difference('Post.count') do
        post admin_posts_url, params: { post: { title: '' } }
      end

      assert_response :unprocessable_entity
    end

    test 'should update a post' do
      post = posts(:first_post)

      patch admin_post_url(post), params: { post: { title: 'Updated Post' } }

      post.reload

      assert_equal('Updated Post', post.title)

      assert_response :see_other

      assert_redirected_to edit_admin_post_path(post)

      assert_equal(I18n.t('admin.posts.update.success'), flash[:success])
    end

    test 'should not update a post with invalid data' do
      post = posts(:first_post)

      patch admin_post_url(post), params: { post: { title: '' } }

      assert_response :unprocessable_entity
    end

    test 'should not update a post that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        patch admin_post_url(id: 'does-not-exist'), params: { post: { title: 'Does Not Exist', body: 'I have nothing to say.' } }
      end
    end

    test 'should destroy a post' do
      post = posts(:first_post)

      assert_difference('Post.count', -1) do
        delete admin_post_url(post)
      end

      assert_response :see_other

      assert_redirected_to admin_posts_path
    end

    test 'should not destroy a post that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete admin_post_url(id: 'does-not-exist')
      end
    end
  end
end
