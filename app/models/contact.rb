# frozen_string_literal: true

class Contact
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name
  attr_accessor :email
  attr_accessor :phone_number
  attr_accessor :subject
  attr_accessor :body

  validates :name, presence: true, length: { maximum: 128 }
  validates :email, presence: true, email: { allow_blank: true }
  validates :phone_number, length: { maximum: 32 }
  validates :subject, presence: true, length: { minimum: 4, maximum: 128, allow_blank: true }
  validates :body, presence: true, length: { minimum: 8, maximum: 2048, allow_blank: true }

  def sanitize!
    @email = email.downcase.strip

    @subject = Sanitize.clean(subject).gsub(/\n|\r|\t/, '').strip

    @body = Sanitize.clean(body).gsub(/\r|\t/, '').split("\n").reject(&:empty?).join("\n").strip

    self
  end
end
