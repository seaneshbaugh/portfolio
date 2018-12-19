# frozen_string_literal: true

class Page < ApplicationRecord
  extend FriendlyId
  include OptionsForSelect

  scope :alphabetical, -> { order(:title) }
  scope :by_order, -> { order(:order) }
  scope :in_menu, -> { where(show_in_menu: true) }
  scope :published, -> { where(visible: true) }
  scope :reverse_alphabetical, -> { order(title: :desc) }

  validates :title, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :body, presence: true, length: { maximum: 16_777_215 }, html: { allow_blank: true }
  validates :style, length: { maximum: 4_194_303 }, css: { allow_blank: true }
  validates :script, length: { maximum: 4_194_303 }, javascript: { allow_blank: true }
  validates :meta_description, length: { maximum: 65535 }
  validates :meta_keywords, length: { maximum: 65535 }
  validates :order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :color, presence: true, css_color: true
  validates :show_in_menu, inclusion: { in: [true, false] }
  validates :visible, inclusion: { in: [true, false] }

  friendly_id :title

  has_paper_trail

  resourcify

  def published?
    visible
  end
end
