# frozen_string_literal: true

class CssValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validation_script = <<~JS
      var css = require('css');
      var source = require('fs').readFileSync(0, 'utf8');
      var parsed = css.parse(source, { silent: true });
      parsed.stylesheet.parsingErrors.forEach(function(error) {
        console.log(error.message);
      });
    JS

    errors, stderr, status = Open3.capture3('node', '-e', validation_script, stdin_data: value)

    unless status.success?
      Rails.logger.error("CSS validation failed: #{stderr}")
      record.errors.add(attribute, 'could not be validated')
      return
    end

    return if errors.blank?

    errors.split("\n").each do |error|
      record.errors.add(attribute, error)
    end
  end
end
