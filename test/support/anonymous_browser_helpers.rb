# frozen_string_literal: true

module AnonymousBrowserHelpers
  def with_anonymous_browser
    # Selenium has one slot. Release the admin browser before opening a visitor.
    page.driver.quit

    Capybara.using_session(:anonymous_visitor) do
      yield
    rescue Minitest::Assertion, StandardError
      take_screenshot

      raise
    ensure
      page.driver.quit
    end
  ensure
    # The next admin visit opens a new browser and establishes its own session.
    sign_in users(:sean_eshbaugh)
  end
end
