# frozen_string_literal: true

class Link < ApplicationRecord
  scope :chronological, -> { order(:published_at) }
  scope :published, -> { where(visible: true) }
  scope :reverse_chronological, -> { order(published_at: :desc) }
  scope :unpublished, -> { where(visible: false) }

  validates :text, presence: true, length: { minimum: 4, maximum: 255 }
  validates :url, presence: true, url: { allow_blank: true }
  validates :description, length: { maximum: 2047 }
  validates :visible, inclusion: { in: [true, false] }

  acts_as_taggable

  has_paper_trail

  resourcify

  def published?
    visible
  end
end
