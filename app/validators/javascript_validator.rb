# frozen_string_literal: true

class JavascriptValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Tempfile.open do |script|
      script.write(value)
      script.flush

      _stdout, stderr, _status = Open3.capture3("node -c #{script.path}")

      if stderr.present?
        stderr.sub!("#{script.path}:", '')

        preamble = '(function (exports, require, module, __filename, __dirname) { '

        if stderr.include?(preamble)
          stderr.sub!(preamble, '')
          stderr.sub!('                                                             ^', '^')
        end

        lines = stderr.split('    at ', 2).first.split("\n")

        message = "#{lines.last} at line #{lines.first}\n #{lines[1..-2].join("\n")}".strip

        record.errors.add(attribute, message)
      end
    end
  end
end
