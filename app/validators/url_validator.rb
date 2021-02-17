# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  DEFAULT_ALLOWED_SCHEMES = %w[
    ftp
    http
    https
    mailto
  ].freeze

  def validate_each(record, attribute, value)
    uri = URI.parse(value)
    host = uri&.host
    scheme = uri&.scheme

    valid_raw_url = scheme && value =~ /\A#{URI::DEFAULT_PARSER.make_regexp([scheme])}\z/
    valid_scheme = host && scheme && valid_schemes.include?(scheme)

    record.errors.add(attribute, options[:message] || :url) unless valid_raw_url && valid_scheme
  rescue URI::InvalidURIError
    record.errors.add(attribute, options[:message] || :url)
  end

  private

  def valid_schemes
    Array(options[:allowed_schemes] || DEFAULT_ALLOWED_SCHEMES)
  end
end
