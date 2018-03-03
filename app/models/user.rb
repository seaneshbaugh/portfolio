# frozen_string_literal: true

class User < ApplicationRecord
  include OptionsForSelect

  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :reverse_alphabetical, -> { order(last_name: :desc, first_name: :desc) }

  %w[read_only user admin sysadmin].each do |role_name|
    scope role_name.to_s.pluralize.to_sym, -> { where(role: role_name) }
  end

  has_many :posts, dependent: :destroy

  validates :email, presence: true, email: { allow_blank: true }, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: %w[read_only user admin sysadmin] }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }

  before_save :define_role

  default_value_for :role, 'read_only'

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_paper_trail only: %i[email role first_name last_name]

  %w[read_only user admin sysadmin].each do |role_name|
    define_method("#{role_name}?") do
      role == role_name.to_s
    end

    define_method("#{role_name}!") do
      self.role = role_name.to_s
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{first_name.first.upcase}. #{last_name}"
  end

  protected

  def define_role
    self.role = %w[read_only user admin sysadmin].include?(role.to_s.downcase) ? role.to_s.downcase : 'read_only'
  end
end
