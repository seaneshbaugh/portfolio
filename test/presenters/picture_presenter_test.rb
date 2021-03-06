# frozen_string_literal: true

require 'test_helper'

class PicturePresenterTest < ActiveSupport::TestCase
  setup do
    attach_images_to_pictures!
  end

  test '#medium_image_tag returns an img tag for the medium image variant' do
    picture = pictures(:cowboy)

    path = picture.medium_image_path

    picture_presenter = PicturePresenter.new(picture, view_context)

    assert_equal("<img alt=\"Cowboy the Cowdog\" class=\"medium-image\" title=\"Cowboy the Cowdog\" src=\"#{path}\" />", picture_presenter.medium_image_tag)
  end

  test '#original_image_tag returns an img tag for the original image variant' do
    picture = pictures(:cowboy)

    path = picture.original_image_path

    picture_presenter = PicturePresenter.new(picture, view_context)

    assert_equal("<img alt=\"Cowboy the Cowdog\" class=\"original-image\" title=\"Cowboy the Cowdog\" src=\"#{path}\" />", picture_presenter.original_image_tag)
  end

  test '#thumbnail_image_tag returns an img tag for the thumbnail image variant' do
    picture = pictures(:cowboy)

    path = picture.thumbnail_image_path

    picture_presenter = PicturePresenter.new(picture, view_context)

    assert_equal("<img alt=\"Cowboy the Cowdog\" class=\"thumbnail-image\" title=\"Cowboy the Cowdog\" src=\"#{path}\" />", picture_presenter.thumbnail_image_tag)
  end
end
