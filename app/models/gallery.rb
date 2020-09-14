# frozen_string_literal: true

class Gallery < ApplicationRecord
  extend FriendlyId

  scope :alphabetical, -> { order(:name) }
  scope :by_order, -> { order(:order) }
  scope :published, -> { where(visible: true) }
  scope :reverse_alphabetical, -> { order(name: :desc) }

  has_many :gallery_pictures, inverse_of: :gallery, dependent: :destroy
  has_many :pictures, through: :gallery_pictures, inverse_of: :galleries

  accepts_nested_attributes_for :gallery_pictures, allow_destroy: true

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :description, length: { maximum: 16_777_215 }, html: { allow_blank: true }
  validates :order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :visible, inclusion: { in: [true, false] }

  friendly_id :name

  has_paper_trail

  resourcify

  def featured_picture
    gallery_pictures.published.featured.by_order.chronological.joins(:picture).first&.picture
  end

  def featured_or_first_picture
    featured_picture || first_picture
  end

  def first_picture
    gallery_pictures.published.by_order.chronological.joins(:picture).first&.picture
  end

  def published?
    visible
  end
end
