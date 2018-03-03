# frozen_string_literal: true

# Taken from https://gist.github.com/olmokramer/82ccce673f86db7cda5e#gistcomment-2174868
class CssColorValidator < ActiveModel::EachValidator
  COLOR_PATTERN = /^(#[0-9a-f]{3}|#(?:[0-9a-f]{2}){2,4}|(rgb|hsl)a?\((-?\d+%?[,\s]+){2,3}\s*[\d\.]+%?\))$/i

  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    record.errors.add(attribute, options[:message] || :invalid) unless value.match?(COLOR_PATTERN)
  end
end
