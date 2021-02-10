# frozen_string_literal: true

class PicturePresenter < ApplicationPresenter
  include Rails.application.routes.url_helpers

  delegate :image_tag, to: :@template
  delegate :key, :filename, :content_type, :metadata, :byte_size, :checksum, to: :'@picture.image.attachment.blob', prefix: :image

  def initialize(picture, template)
    super

    @picture = picture
  end

  # TODO: Maybe figure out a more elegant way to handle this.
  def formatted_exif
    model = image_metadata.dig('exif', 'model')
    lens_model = image_metadata.dig('exif', 'lens_model')
    date_time = image_metadata.dig('exif', 'date_time')
    exposure_time = image_metadata.dig('exif', 'exposure_time')
    f_number = image_metadata.dig('exif', 'f_number')
    iso_speed_ratings = image_metadata.dig('exif', 'iso_speed_ratings')
    focal_length = image_metadata.dig('exif', 'focal_length')

    return '' unless model && lens_model && date_time && exposure_time && f_number && iso_speed_ratings && focal_length

    f_number = Rational(*f_number.split('/').map(&:to_i)).to_f.to_s if f_number

    focal_length = Rational(*focal_length.split('/').map(&:to_i)).to_f.to_s if focal_length

    # TODO: i18n this.
    "Model: #{model}, Lens: #{lens_model}, Exposure: #{exposure_time}, F-Number: #{f_number}, ISO: #{iso_speed_ratings}, Focal Length: #{focal_length}mm"
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
