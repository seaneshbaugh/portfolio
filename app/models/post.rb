class Post < ActiveRecord::Base
  include OptionsForSelect
  include Slugable

  # Scopes
  scope :alphabetical, -> { order(:title) }

  scope :chronological, -> { order(:created_at) }

  scope :published, -> { where(visible: true) }

  scope :reverse_alphabetical, -> { order('posts.title DESC') }

  scope :reverse_chronological, -> { order('posts.created_at DESC') }

  # Associations
  belongs_to :user

  # Validations
  validates_presence_of :user_id

  validates_length_of :title, maximum: 255
  validates_presence_of :title
  validates_uniqueness_of :title

  validates_length_of :body, maximum: 16_777_215

  validates_length_of :style, maximum: 4_194_303

  validates_length_of :script, maximum: 4_194_303

  validates_length_of :meta_description, maximum: 65535

  validates_length_of :meta_keywords, maximum: 65535

  validates_inclusion_of :visible, in: [true, false], message: 'must be true or false'

  validates_associated :user

  # Default Values
  default_value_for :title, ''

  default_value_for :slug, ''

  default_value_for :body, ''

  default_value_for :style, ''

  default_value_for :script, ''

  default_value_for :meta_description, ''

  default_value_for :meta_keywords, ''

  default_value_for :visible, true

  acts_as_taggable

  has_paper_trail

  def first_image
    images = Nokogiri::HTML(body).xpath('//img')

    images[0]['src'] if images.length > 0
  end

  def more
    if body.include?('<!--more-->')
      body[0..body.index('<!--more-->') - 1]
    else
      body
    end
  end

  def published?
    visible
  end

  def truncated?
    body.length > more.length
  end
end
