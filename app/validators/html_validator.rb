# frozen_string_literal: true

class HtmlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    document_fragment = Nokogiri::HTML5.fragment(value, max_errors: 1)

    document_fragment.errors.each do |nokogiri_error|
      record.errors.add(attribute, nokogiri_error.to_s)
    end
  end
end
