# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  add_group 'Presenters', 'app/presenters'
  add_group 'Validators', 'app/validators'
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'

Minitest::Reporters.use!

DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

# module FixtureFileHelpers
#   include ActionDispatch::TestProcess::FixtureFile

#   def fixture_file_upload(path, mime_type = nil, binary = false)
#     puts `pwd`
#     super(Rails.root.join('test', 'fixtures', 'files', path), mime_type, binary)
#   end
# end
# ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
