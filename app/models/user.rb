require 'digest/sha2'
require 'RFC2822'

class User < ActiveRecord::Base
  attr_accessor :password

  has_many :posts, :dependent => :destroy
  has_paper_trail

  before_create { generate_token(:remember_me_token) }
  before_save :encrypt_password, :scrub

  validates :email_address,
    :presence => true,
    :uniqueness => true,
    :length => { :minimum => 3, :maximum => 254 },
    :format => { :with => RFC2822::EmailAddress },
    :confirmation => true

  validates :password,
    :presence => true,
    :length => { :minimum => 6, :maximum => 32 },
    :format => { :with => /^([\x20-\x7E]){6,32}$/ },
    :confirmation => true,
    :on => :create

  validates :first_name,
    :presence => true

  validates :last_name,
    :presence => true

  validates :phone_number,
    :format => { :with => /^(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/ }

  validates :privilege_level,
    :presence => true,
    :numericality => true

  validates :login_count,
    :presence => true,
    :numericality => true

  validates :post_count,
    :presence => true,
    :numericality => true

  PrivilegeLevelGuest     = 0
  PrivilegeLevelUser      = 1
  PrivilegeLevelModerator = 2
  PrivilegeLevelAdmin     = 3
  PrivilegeLevelSysOp     = 4

  def generate_token(column)
    begin
      self[column] = SecureRandom.base64(9)
    end while User.exists?(column => self[column])
  end

  def encrypt_password
    if password.present?
      self.password_salt = SecureRandom.base64(9)

      self.password_hash = Digest::SHA256.hexdigest(password + self.password_salt)
    end
  end

  def scrub
    self.email_address.downcase!
  end

  def send_password_reset
    generate_token(:password_reset_token)

    self.password_reset_sent_at = Time.zone.now

    save!

    UserMailer.password_reset(self).deliver
  end

  def self.authenticate(email_address, password)
    user = find_by_email_address(email_address)

    if user && user.password_hash == Digest::SHA256.hexdigest(password + user.password_salt)
      user
    else
      nil
    end
  end

  def self.search(search)
    if search
      #where("name LIKE ?", "%#{search}%")
      where("first_name LIKE :search OR last_name LIKE :search OR email_address LIKE :search OR phone_number LIKE :search", { :search => "%#{search}%" })
    else
      scoped
    end
  end
end