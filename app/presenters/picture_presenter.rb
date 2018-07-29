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
    image_tag medium_image_path, alt: @picture.alt_text, class: 'medium-image', title: @picture.title
  end

  def original_image_tag
    image_tag original_image_path, alt: @picture.alt_text, class: 'original-image', title: @picture.title
  end

  def thumbnail_image_tag
    image_tag thumbnail_image_path, alt: @picture.alt_text, class: 'thumbnail-image', title: @picture.title
  end
end
