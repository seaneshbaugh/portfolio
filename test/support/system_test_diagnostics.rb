module SystemTestDiagnostics
  extend ActiveSupport::Concern

  included do
    teardown do
      unless passed?
        directory = Rails.root.join("tmp/screenshots")
        FileUtils.mkdir_p(directory)
        File.write(directory.join("#{name.parameterize}-console.json"), JSON.pretty_generate(captured_logs))
      end
    rescue Selenium::WebDriver::Error::WebDriverError, IOError, SystemCallError => error
      warn "Unable to save browser logs: #{error.message}"
    end
  end

  def visit(...)
    super.tap { capture_logs! }
  end
end
