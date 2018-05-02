# frozen_string_literal: true

class Picture < ApplicationRecord
#  has_attached_file :image, path: :attachment_path, styles: ->(_) { attachment_styles }, url: :attachment_url

  scope :chronological, -> { order(:created_at) }
  scope :reverse_chronological, -> { order(created_at: :desc) }

  validates :title, presence: true, length: { maximum: 65535 }
  validates :alt_text, length: { maximum: 65535 }
  validates :caption, length: { maximum: 65535 }
  # validates :image_fingerprint, uniqueness: { if: -> { !Rails.env.test? } }
  # validates_attachment_presence :image
  # validates_attachment_size :image, less_than: 1024.megabytes
  # validates_attachment_content_type :image, content_type: %w[image/gif image/jpeg image/jpg image/pjpeg image/png image/svg+xml image/tiff image/x-png]

  before_validation :ensure_title
  # before_validation :normalize_image_file_name
  # after_post_process :save_image_dimensions

  resourcify

  def self.attachment_styles
    {
      thumb: {
        geometry: '100x100',
        format: :jpg,
        convert_options: '-quality 75 -strip'
      },
      medium: {
        geometry: '300x300',
        format: :jpg,
        convert_options: '-quality 85 -strip'
      }
    }
  end

  def attachment_path
    ":rails_root/public/uploads/#{Rails.env.test? ? 'test/' : ''}:class_singular/:attachment/:style_prefix:basename.:extension"
  end

  def attachment_url
    "/uploads/:class_singular/:attachment/#{Rails.env.test? ? 'test/' : ''}:style_prefix:basename.:extension"
  end

  private

  def default_title
    File.basename(image_file_name, '.*').to_s
  end

  def ensure_title
    self.title = default_title if title.blank? && image_file_name.present?
  end

  def normalize_image_file_name
    return unless image.file? && image.dirty?

    current_time = Time.now

    basename = "#{current_time.to_i}#{current_time.usec}".ljust(16, '0')

    extension = File.extname(image_file_name).downcase

    extension = '.jpg' if extension == '.jpeg'

    extension = '.tiff' if extension == '.tif'

    image.instance_write(:file_name, "#{basename}#{extension}")
  end

  # def save_image_dimensions
  #   original_geometry = Paperclip::Geometry.from_file(image.queued_for_write[:original])

  #   self.image_original_width = original_geometry.width
  #   self.image_original_height = original_geometry.height

  #   medium_geometry = Paperclip::Geometry.from_file(image.queued_for_write[:medium])

  #   self.image_medium_width = medium_geometry.width
  #   self.image_medium_height = medium_geometry.height

  #   thumb_geometry = Paperclip::Geometry.from_file(image.queued_for_write[:thumb])

  #   self.image_thumb_width = thumb_geometry.width
  #   self.image_thumb_height = thumb_geometry.height
  # end
end
