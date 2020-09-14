# frozen_string_literal: true

class GalleryPicture < ApplicationRecord
  scope :by_order, -> { order(:order) }
  scope :featured, -> { where(featured: true) }
  scope :published, -> { where(visible: true) }

  belongs_to :gallery, inverse_of: :gallery_pictures
  belongs_to :picture, inverse_of: :gallery_pictures

  validates :gallery_id, presence: true
  validates_associated :gallery
  validates :featured, inclusion: { in: [true, false] }
  validates :visible, inclusion: { in: [true, false] }
end
