# frozen_string_literal: true

require 'test_helper'

class PicturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    attach_images_to_pictures!
  end

  test 'should get pictures index' do
    get pictures_url

    assert_response :ok
  end

  test 'should show a picture gallery' do
    gallery = galleries(:salt_plains)

    get picture_url(gallery)

    assert_response :ok
  end

  test 'should not show a picture gallery that does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) do
      get picture_url(id: 'does-not-exist')
    end
  end
end
