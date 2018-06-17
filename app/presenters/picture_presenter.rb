# frozen_string_literal: true

class PicturePresenter < BasePresenter
  include Rails.application.routes.url_helpers

  delegate :image_tag, to: :@template

  def initialize(picture, template)
    super

    @picture = picture
  end

  # TODO: Consider DRYing this?

  def medium_image_tag
    image_tag medium_image_path, alt: @picture.alt_text, class: 'medium', style: 'max-height: 300px;', title: @picture.title
  end

  def medium_image_path
    rails_blob_path(@picture.image, only_path: true)
  end

  def medium_image_url
    rails_blob_url(@picture.image)
  end

  def original_image_tag
    image_tag original_image_path, alt: @picture.alt_text, class: 'original', title: @picture.title
  end

  def original_image_path
    rails_blob_path(@picture.image, only_path: true)
  end

  def original_image_url
    rails_blob_url(@picture.image)
  end

  def thumbnail_image_tag
    image_tag thumbnail_image_path, alt: @picture.alt_text, class: 'thumb', style: 'max-height: 50px;', title: @picture.title
  end

  def thumbnail_image_path
    rails_blob_path(@picture.image, only_path: true)
  end

  def thumbnail_image_url
    rails_blob_url(@picture.image)
  end
end
