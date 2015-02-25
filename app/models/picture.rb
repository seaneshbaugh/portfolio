class Picture < ActiveRecord::Base
  has_attached_file :image,
                    # convert_options: -> (_) { attachment_convert_options },
                    path: :attachment_path,
                    styles: -> (_) { attachment_styles },
                    url: :attachment_url

  # Scopes
  scope :chronological, -> { order(:created_at) }

  scope :reverse_chronological, -> { order('pictures.created_at DESC') }

  # Validations
  validates_length_of :title, maximum: 65535
  validates_presence_of :title

  validates_length_of :alt_text, maximum: 65535

  validates_length_of :caption, maximum: 65535

  validates_uniqueness_of :image_fingerprint, if: -> { !Rails.env.test? }

  validates_attachment_presence :image
  validates_attachment_size :image, less_than: 1024.megabytes
  validates_attachment_content_type :image, content_type: %w(image/gif image/jpeg image/jpg image/pjpeg image/png image/svg+xml image/tiff image/x-png)

  # Callbacks
  before_validation :modify_image_file_name

  before_validation :set_default_title

  after_post_process :save_image_dimensions

  # Default Values
  default_value_for :title, ''

  default_value_for :alt_text, ''

  default_value_for :caption, ''

  default_value_for :image_original_width, 1

  default_value_for :image_original_height, 1

  default_value_for :image_medium_width, 1

  default_value_for :image_medium_height, 1

  default_value_for :image_thumb_width, 1

  default_value_for :image_thumb_height, 1

  def self.attachment_convert_options
    {}
    # {
    #   thumb: '-quality 75 -strip',
    #   medium: '-quality 85 -strip'
    # }
  end

  def self.attachment_styles
    {
      thumb: '100x100',
      medium: '300x300'
    }
  end

  def attachment_path
    ":rails_root/public/uploads/#{Rails.env.test? ? 'test/' : ''}:class_singular/:attachment/:style_prefix:basename.:extension"
  end

  def attachment_url
    "/uploads/:class_singular/:attachment/#{Rails.env.test? ? 'test/' : ''}:style_prefix:basename.:extension"
  end

  protected

  def modify_image_file_name
    return unless image.file? && image.dirty?

    current_time = Time.now

    basename = "#{current_time.to_i}#{current_time.usec}".ljust(16, '0')

    extension = File.extname(image_file_name).downcase

    extension = '.jpg' if extension == '.jpeg'

    extension = '.tiff' if extension == '.tif'

    image.instance_write :file_name, "#{basename}#{extension}"
  end

  def save_image_dimensions
    original_geometry = Paperclip::Geometry.from_file(image.queued_for_write[:original])
    self.image_original_width = original_geometry.width
    self.image_original_height = original_geometry.height

    medium_geometry = Paperclip::Geometry.from_file(image.queued_for_write[:medium])
    self.image_medium_width = medium_geometry.width
    self.image_medium_height = medium_geometry.height

    thumb_geometry = Paperclip::Geometry.from_file(image.queued_for_write[:thumb])
    self.image_thumb_width = thumb_geometry.width
    self.image_thumb_height = thumb_geometry.height
  end

  def set_default_title
    self.title = File.basename(image_file_name, '.*').to_s if title.blank? && !image_file_name.blank?
  end
end
