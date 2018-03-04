# frozen_string_literal: true

class Post < ApplicationRecord
  include FriendlyId
  include OptionsForSelect

  scope :alphabetical, -> { order(:title) }
  scope :chronological, -> { order(:created_at) }
  scope :published, -> { where(visible: true) }
  scope :reverse_alphabetical, -> { order(title: :desc) }
  scope :reverse_chronological, -> { order(created_at: :desc) }
  scope :unpublished, -> { where(visible: false) }

  belongs_to :user

  validates :user_id, presence: true
  validates_associated :user
  validates :title, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :body, presence: true, length: { maximum: 16_777_215 }
  validates :style, presence: true, length: { maximum: 4_194_303 }
  validates :script, presence: true, length: { maximum: 4_194_303 }
  validates :meta_description, presence: true, length: { maximum: 65535 }
  validates :meta_keywords, presence: true, length: { maximum: 65535 }
  validates :visible, inclusion: { in: [true, false] }

  acts_as_taggable

  friendly_id :title, use: :slugged

  has_paper_trail

  def published?
    visible
  end
end
