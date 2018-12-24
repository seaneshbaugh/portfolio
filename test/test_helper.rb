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

DatabaseCleaner.strategy = :transaction

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    setup do
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
    end

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
