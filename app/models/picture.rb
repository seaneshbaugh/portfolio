# frozen_string_literal: true

class Picture < ApplicationRecord
  include FriendlyId
  include Rails.application.routes.url_helpers

  has_many :gallery_pictures, inverse_of: :picture, dependent: :destroy
  has_many :galleries, through: :gallery_pictures, inverse_of: :pictures
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 65535 }
  validates :alt_text, length: { maximum: 65535 }
  validates :caption, length: { maximum: 65535 }
  validates :image, image_attachment: true

  before_validation :ensure_title

  friendly_id :timestamp

  resourcify

  def image_filename
    image.blob.filename.to_s if image.attached?
  end

  # TODO: Consider DRYing this?
  def medium_image_path
    rails_representation_url(image.variant(resize_to_limit: [500, nil]), only_path: true)
  end

  def medium_image_url
    rails_representation_url(image.variant(resize_to_limit: [500, nil]))
  end

  def original_image_path
    rails_blob_path(image, only_path: true)
  end

  def original_image_url
    rails_blob_url(image)
  end

  def thumbnail_image_path
    rails_representation_url(image.variant(resize_to_limit: [100, nil]), only_path: true)
  end

  def thumbnail_image_url
    rails_representation_url(image.variant(resize_to_limit: [100, nil]))
  end

  private

  def default_title
    File.basename(image_filename, '.*').to_s
  end

  def ensure_title
    self.title = default_title if title.blank? && image_filename.present?
  end

  def timestamp
    current_time = Time.now.utc

    "#{current_time.to_i}#{current_time.usec}".ljust(16, '0')
  end
end
