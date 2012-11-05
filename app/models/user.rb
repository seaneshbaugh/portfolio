class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :role, :first_name, :last_name, :remember_me

  has_paper_trail :only => [:email, :role, :first_name, :last_name]

  has_many :posts

  validates_format_of     :email, :with => Devise.email_regexp, :allow_blank => true
  validates_presence_of   :email
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true

  validates_confirmation_of :password
  validates_length_of       :password, :within => 6..255, :if => :password_required?
  validates_presence_of     :password, :if => :password_required?

  validates_presence_of :first_name

  validates_presence_of :last_name

  default_scope :order => 'last_name ASC'

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def short_name
    "#{self.first_name.first.upcase}. #{self.last_name}"
  end

  protected

  def password_required?
    !self.persisted? || !self.password.blank? || !self.password_confirmation.blank?
  end
end
