# frozen_string_literal: true

class CssValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validation_script = <<-JS
    var css = require('css');
    var parsed = css.parse('#{value}', { silent: true });
    parsed.stylesheet.parsingErrors.forEach(function(error) {
      console.log(error.message);
    });
    JS

    errors = `node -e "#{validation_script}"`

    return if errors.blank?

    errors.split("\n").each do |error|
      record.errors.add(attribute, error)
    end
  end
end
