# frozen_string_literal: true

class Post < ApplicationRecord
  include FriendlyId

  scope :alphabetical, -> { order(:title) }
  scope :published, -> { where(visible: true) }
  scope :reverse_alphabetical, -> { order(title: :desc) }
  scope :unpublished, -> { where(visible: false) }

  belongs_to :user

  validates :user_id, presence: true
  validates_associated :user
  validates :title, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :body, presence: true, length: { minimum: 4, maximum: 16_777_215 }, html: { allow_blank: true }
  validates :style, length: { maximum: 4_194_303 }, css: { allow_blank: true }
  validates :script, length: { maximum: 4_194_303 }, javascript: { allow_blank: true }
  validates :meta_description, length: { maximum: 65535 }
  validates :meta_keywords, length: { maximum: 65535 }
  validates :visible, inclusion: { in: [true, false] }

  acts_as_taggable

  friendly_id :title

  has_paper_trail

  resourcify

  def published?
    visible
  end
end
