# frozen_string_literal: true

class User < ApplicationRecord
  include FriendlyId
  include SlugNormalization

  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :reverse_alphabetical, -> { order(last_name: :desc, first_name: :desc) }

  has_many :posts, dependent: :destroy

  validates :email, presence: true, email: { allow_blank: true }, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }

  after_commit :assign_default_role, on: :create

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  friendly_id :full_name

  has_paper_trail only: %i[email first_name last_name]

  rolify

  ransacker :role_name do
    Arel.sql(<<~SQL.squish)
      (SELECT MIN(roles.name) FROM roles
       INNER JOIN users_roles ON users_roles.role_id = roles.id
       WHERE users_roles.user_id = users.id)
    SQL
  end

  resourcify :other_users

  def self.ransackable_associations(auth_object = nil)
    %w[roles]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[first_name last_name email created_at role_name]
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Rolify checks before inserting both roles and assignments. A competing writer
  # can win either insert; retry once with a fresh association after that conflict.
  # Without the unique indexes added on roles and users_roles add_roles could
  # potentially add duplicate roles or users_roles, but with the unique indexes
  # a concurrent call to add_user can raise, this ensures the call that lost the
  # race can retry gracefully. This is an issue with Rolify, and likely has to do
  # with needing to maintain SQL database compatibility; nulls_not_distinct, which
  # makes the unique index on roles work is Postgres only.
  def add_role(role_name, resource = nil)
    retried = false

    begin
      self.class.transaction(requires_new: true) { super }
    rescue ActiveRecord::RecordNotUnique => error
      constraint = error.cause&.result&.error_field(PG::Result::PG_DIAG_CONSTRAINT_NAME)

      raise if retried || !%w[index_roles_on_name_and_resource_type_and_resource_id index_users_roles_on_user_id_and_role_id].include?(constraint)

      retried = true

      roles.reset

      retry
    end
  end

  alias_method :grant, :add_role

  private

  def assign_default_role
    add_role(:user) if roles.blank?
  end
end
