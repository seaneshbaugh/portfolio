require 'digest/sha2'
require 'RFC2822'

class User < ActiveRecord::Base
  attr_reader :password

  has_paper_trail

  has_many :sessions, :dependent => :destroy

  validates_uniqueness_of :name

  validates_uniqueness_of :email_address

  validates_format_of :email_address, :with => RFC2822::EmailAddress

  validates_format_of :name, :with => /^([a-z0-9_]{4,16})$/i

  validates_format_of :password, :with => /^([\x20-\x7E]){6,32}$/, :unless => :password_is_not_being_updated?

  validates_format_of :phone_number, :with => /^(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/

  validates_confirmation_of :password, :email_address

  validates_presence_of :name, :email_address, :first_name, :last_name

  before_save :scrub_name

  after_save :flush_passwords

  PrivilegeLevelGuest   = 0
  PrivilegeLevelUser    = 1
  PrivilegeLevelModerator = 2
  PrivilegeLevelAdmin   = 3
  PrivilegeLevelSysOp   = 4

  def self.find_by_name_and_password(name, password)
    user = self.find_by_name(name)

    if user and user.encrypted_password == Digest::SHA256.hexdigest(password + user.salt)
      return user
    end
  end

  def password=(password)
    @password = password

    unless password_is_not_being_updated?
      self.salt = [Array.new(9){rand(256).chr}.join].pack('m').chomp

      self.encrypted_password = Digest::SHA256.hexdigest(password + self.salt)
    end
  end

  def update_ip_log(remote_ip)
    unless self.ip_addresses.blank?
      ips = self.ip_addresses.split(";")

      if ips.index(remote_ip).nil?
        ips << remote_ip
      end

      ips = ips.last(15)

      self.ip_addresses = ips.join(";") + ";"
    else
      self.ip_addresses = remote_ip + ";"
    end
  end

  def generate_cookie_code
    self.cookie_code = ""

    chars = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a

    128.times do
      self.cookie_code << chars[rand(chars.length - 1)]
    end

    return self.cookie_code
  end

  private

  def scrub_name
    self.name.downcase!
  end

  def flush_passwords
    @password = @password_confirmation = nil
  end

  def password_is_not_being_updated?
    self.id and self.password.blank?
  end
end
