# frozen_string_literal: true

# Taken from https://github.com/gitlabhq/gitlabhq/blob/master/app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    record.errors.add(attribute, options[:message] || :invalid) unless value.match?(Devise.email_regexp)
  end
end
