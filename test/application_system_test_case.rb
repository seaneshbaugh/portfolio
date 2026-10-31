require "test_helper"
require_relative "support/system_test_diagnostics"

Capybara.server = :puma, { Silent: true }
Capybara.server_host = "0.0.0.0"
Capybara.server_port = 3001
Capybara.app_host = "http://web:3001"
Capybara.enable_aria_label = true

Capybara.register_driver :remote_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument("-headless")

  Capybara::Selenium::Driver.new(app, browser: :remote, url: "http://selenium:4444", options:)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestDiagnostics

  # Remote Firefox tests share one server port and browser container. This
  # prevents multiple processes from attempting to bind to port 3001. The
  # downside of this is that running `rails test:all` will now run all
  # tests sequentially. In order for non-system tests to be run in parallel
  # they should be run separately with `rails test` and `rails test:system`.
  # If this project's tests are ever run as part of a CI pipeline then they
  # should be run separately.
  parallelize(workers: 1)

  driven_by :remote_firefox, screen_size: [ 1400, 1400 ]

  def assert_eventually(timeout: Capybara.default_max_wait_time)
    Timeout.timeout(timeout) do
      loop do
        return if yield

        sleep 0.05
      end
    end
  rescue Timeout::Error
    flunk "condition was not met within #{timeout} seconds"
  end

  def capture_logs!
    page.execute_script(<<~JS)
      window.jsLogs = [];
      ["log", "error", "warn", "info"].forEach((level) => {
        const original = console[level];
        console[level] = function(...args) {
          window.jsLogs.push({ level, message: args.join(" ") });
          original.apply(console, args);
        };
      });
    JS
  end

  def clear_captured_logs!
    page.evaluate_script("window.jsLogs = []")
  end

  def captured_logs
    page.evaluate_script("window.jsLogs || []")
  end
end
