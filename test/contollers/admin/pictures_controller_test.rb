# frozen_string_literal: true

require 'test_helper'

module Admin
  class PicturesControllerTest < ActionController::TestCase
    setup do
      attach_images_to_pictures!

      sign_in users(:sean_eshbaugh)
    end

    test 'should get pictures index' do
      get :index

      assert_response :ok
    end

    test 'should show a picture' do
      picture = pictures(:conney)

      get :show, params: { id: picture }

      assert_response :ok
    end

    test 'should not show a picture that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { id: 'does-not-exist' }
      end
    end

    test 'should get a new picture' do
      get :new

      assert_response :ok
    end

    test 'should get a picture to edit' do
      picture = pictures(:cowboy)

      get :edit, params: { id: picture }

      assert_response :ok
    end

    test 'should not get a picture that does not exist to edit' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, params: { id: 'does-not-exist' }
      end
    end

    test 'should create a picture' do
      assert_difference('Picture.count', 1) do
        post :create, params: { picture: { title: 'New Picture', body: 'Testing 1 2 3', image: fixture_file_upload('conney-the-corgi.jpg', 'image/jpeg', true) } }
      end

      assert_response :see_other

      assert_redirected_to admin_picture_path(Picture.chronological.last)
    end

    test 'should not create an invalid picture' do
      assert_no_difference('Picture.count') do
        post :create, params: { picture: { title: 'Image Intentionally Left Blank' } }
      end

      assert_response :unprocessable_entity
    end

    test 'should update a picture' do
      picture = pictures(:conney)

      patch :update, params: { id: picture, picture: { title: 'Updated Picture' } }

      picture.reload

      assert picture.title == 'Updated Picture'

      assert_response :see_other

      assert_redirected_to edit_admin_picture_path(picture)

      assert_equal I18n.t('admin.pictures.update.success'), flash[:success]
    end

    test 'should not update a picture with invalid data' do
      picture = pictures(:cowboy)

      patch :update, params: { id: picture, picture: { title: 'A' * 65536 } }

      assert_response :unprocessable_entity
    end

    test 'should not update a picture that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        patch :update, params: { id: 'does-not-exist', picture: { title: 'Does Not Exist', body: 'Picture intentionally left blank.' } }
      end
    end

    test 'should destroy a picture' do
      picture = pictures(:conney)

      assert_difference('Picture.count', -1) do
        delete :destroy, params: { id: picture }
      end

      assert_response :see_other

      assert_redirected_to admin_pictures_path
    end

    test 'should not destroy a picture that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete :destroy, params: { id: 'does-not-exist' }
      end
    end
  end
end
