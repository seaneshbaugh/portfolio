class Session < ActiveRecord::Base
  attr_accessor :name, :password, :match

  belongs_to :user

  before_validation :authenticate_user

  validates_presence_of :match, :message => "The name and password combination you provided could not be found.", :unless => :session_has_been_associated?

  before_save :associate_session_to_user

  before_save :remove_duplicates

  private

  def authenticate_user
    self.match = User.find_by_name_and_password(self.name, self.password) unless session_has_been_associated?
  end

  def associate_session_to_user
    self.user_id ||= self.match.id
  end

  def session_has_been_associated?
    self.user_id
  end

  def remove_duplicates
    duplicates = Session.find_all_by_user_id_and_ip_address(self.user_id, self.ip_address)

    if !duplicates.nil?
      duplicates.delete(self)
    end

    for duplicate in duplicates
      Session.destroy(duplicate)
    end
  end
end
