# frozen_string_literal: true

require 'test_helper'

module Admin
  class PicturesControllerTest < ActionDispatch::IntegrationTest
    setup do
      attach_images_to_pictures!

      sign_in users(:sean_eshbaugh)
    end

    test 'should get pictures index' do
      get admin_pictures_url

      assert_response :ok
    end

    test 'should show a picture' do
      picture = pictures(:conney)

      get admin_picture_url(picture)

      assert_response :ok
    end

    test 'should not show a picture that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get admin_picture_url(id: 'does-not-exist')
      end
    end

    test 'should get a new picture' do
      get new_admin_picture_url

      assert_response :ok
    end

    test 'should get a picture to edit' do
      picture = pictures(:cowboy)

      get edit_admin_picture_url(picture)

      assert_response :ok
    end

    test 'should not get a picture that does not exist to edit' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get edit_admin_picture_url(id: 'does-not-exist')
      end
    end

    test 'should create a picture' do
      assert_difference('Picture.count', 1) do
        post admin_pictures_url, params: { picture: { title: 'New Picture', body: 'Testing 1 2 3', image: fixture_file_upload('conney-the-corgi.jpg', 'image/jpeg', true) } }
      end

      assert_response :see_other

      assert_redirected_to admin_picture_path(Picture.chronological.last)
    end

    test 'should not create an invalid picture' do
      assert_no_difference('Picture.count') do
        post admin_pictures_url, params: { picture: { title: 'Image Intentionally Left Blank' } }
      end

      assert_response :unprocessable_entity
    end

    test 'should update a picture' do
      picture = pictures(:conney)

      patch admin_picture_url(picture), params: { picture: { title: 'Updated Picture' } }

      picture.reload

      assert_equal('Updated Picture', picture.title)

      assert_response :see_other

      assert_redirected_to edit_admin_picture_path(picture)

      assert_equal(I18n.t('admin.pictures.update.success'), flash[:success])
    end

    test 'should not update a picture with invalid data' do
      picture = pictures(:cowboy)

      patch admin_picture_url(picture), params: { picture: { title: 'A' * 65536 } }

      assert_response :unprocessable_entity
    end

    test 'should not update a picture that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        patch admin_picture_url(id: 'does-not-exist'), params: { picture: { title: 'Does Not Exist', body: 'Picture intentionally left blank.' } }
      end
    end

    test 'should destroy a picture' do
      picture = pictures(:conney)

      assert_difference('Picture.count', -1) do
        delete admin_picture_url(picture)
      end

      assert_response :see_other

      assert_redirected_to admin_pictures_path
    end

    test 'should not destroy a picture that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete admin_picture_url(id: 'does-not-exist')
      end
    end
  end
end
