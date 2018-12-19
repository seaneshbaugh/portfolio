# frozen_string_literal: true

require 'test_helper'

class HtmlValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    include ActiveModel::Validations
    attr_accessor :body
    validates :body, html: true
  end

  test 'valid HTML' do
    dummy_object = DummyClass.new

    dummy_object.body = '<h1>Hello, world!</h1>'

    assert dummy_object.valid?
  end

  test 'invalid HTML' do
    dummy_object = DummyClass.new

    dummy_object.body = '<h1>Hello, world!</h1'

    assert_not dummy_object.valid?

    assert dummy_object.errors[:body] == ["1:22: ERROR: End of input in tag.\n<h1>Hello, world!</h1\n                     ^"]
  end
end
