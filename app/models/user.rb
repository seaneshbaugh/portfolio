# frozen_string_literal: true

class User < ApplicationRecord
  include OptionsForSelect

  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :reverse_alphabetical, -> { order(last_name: :desc, first_name: :desc) }

  has_many :posts, dependent: :destroy

  validates :email, presence: true, email: { allow_blank: true }, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }

  after_create :assign_default_role

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  rolify

  has_paper_trail only: %i[email first_name last_name]

  private

  def assign_default_role
    add_role(:user) if roles.blank?
  end
end
