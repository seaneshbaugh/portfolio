# frozen_string_literal: true

require 'test_helper'

module Admin
  class GalleriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      attach_images_to_pictures!

      sign_in users(:sean_eshbaugh)
    end

    test 'should get galleries index' do
      get admin_galleries_url

      assert_response :ok
    end

    test 'should show a gallery' do
      gallery = galleries(:salt_plains)

      get admin_gallery_url(gallery)

      assert_response :ok
    end

    test 'should not show a gallery that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get admin_gallery_url(id: 'does-not-exist')
      end
    end

    test 'should get a new gallery' do
      get new_admin_gallery_url

      assert_response :ok
    end

    test 'should get a gallery to edit' do
      gallery = galleries(:salt_plains)

      get edit_admin_gallery_url(gallery)

      assert_response :ok
    end

    test 'should not get a gallery that does not exist to edit' do
      assert_raises(ActiveRecord::RecordNotFound) do
        get edit_admin_gallery_url(id: 'does-not-exist')
      end
    end

    test 'should create a gallery' do
      assert_difference('Gallery.count', 1) do
        post admin_galleries_url, params: { gallery: { name: 'New Gallery', description: 'Testing 1 2 3', order: 0, visible: true } }
      end

      assert_response :see_other

      assert_redirected_to admin_gallery_path(Gallery.chronological.last)
    end

    test 'should not create an invalid gallery' do
      assert_no_difference('Gallery.count') do
        post admin_galleries_url, params: { gallery: { description: 'Name Intentionally Left Blank' } }
      end

      assert_response :unprocessable_entity
    end

    test 'should update a gallery' do
      gallery = galleries(:salt_plains)

      patch admin_gallery_url(gallery), params: { gallery: { name: 'Updated Gallery' } }

      gallery.reload

      assert_equal('Updated Gallery', gallery.name)

      assert_response :see_other

      assert_redirected_to edit_admin_gallery_path(gallery)

      assert_equal(I18n.t('admin.galleries.update.success'), flash[:success])
    end

    test 'should not update a gallery with invalid data' do
      gallery = galleries(:salt_plains)

      patch admin_gallery_url(gallery), params: { gallery: { name: 'A' * 65536 } }

      assert_response :unprocessable_entity
    end

    test 'should not update a gallery that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        patch admin_gallery_url(id: 'does-not-exist'), params: { gallery: { name: 'Does Not Exist', description: 'Gallery intentionally left blank.' } }
      end
    end

    test 'should destroy a gallery' do
      gallery = galleries(:salt_plains)

      assert_difference('Gallery.count', -1) do
        delete admin_gallery_url(gallery)
      end

      assert_response :see_other

      assert_redirected_to admin_galleries_path
    end

    test 'should not destroy a gallery that does not exist' do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete admin_gallery_url(id: 'does-not-exist')
      end
    end
  end
end
