# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  add_group 'Builders', 'app/builders'
  add_group 'Policies', 'app/policies'
  add_group 'Presenters', 'app/presenters'
  add_group 'Serializers', 'app/serializers'
  add_group 'Validators', 'app/validators'
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'minitest/reporters'

mean_time_reporter_options = {
  previous_runs_filename: Rails.root.join('tmp', 'minitest_reporters_previous_run'),
  report_filename: Rails.root.join('tmp', 'minitest_reporters_report')
}

Minitest::Reporters.use! Minitest::Reporters::MeanTimeReporter.new(mean_time_reporter_options)

Webpacker.compile

module ActiveSupport
  self.test_order = :random

  class TestCase
    class << self
      alias context describe
    end

    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    fixtures :all

    # Add more helper methods to be used by all tests here...

    private

    def fixture_file_path(filename)
      Rails.root.join('test', 'fixtures', 'files', filename)
    end

    def attach_images_to_pictures!
      Picture.find_each do |picture|
        filename = "#{picture.title.parameterize}.jpg"

        picture.image.attach(io: File.open(fixture_file_path(filename)), filename: filename)
      end
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers

    def fixture_file_upload(filename, mime_type = nil, binary = false)
      super(fixture_file_path(filename), mime_type, binary)
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
