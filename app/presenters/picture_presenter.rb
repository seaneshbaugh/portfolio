# frozen_string_literal: true

class PicturePresenter < BasePresenter
  include Rails.application.routes.url_helpers

  delegate :image_tag, to: :@template
  delegate :key, :filename, :content_type, :metadata, :byte_size, :checksum, to: :'@picture.image.attachment.blob', prefix: :image

  def initialize(picture, template)
    super

    @picture = picture
  end

  def image_size(pretty = true)
    return "#{image_byte_size.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse} bytes" unless pretty

    Filesize.new(image_byte_size).pretty
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
