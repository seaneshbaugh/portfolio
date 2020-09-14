# frozen_string_literal: true

require 'test_helper'

class CssValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :style

    validates :style, css: true
  end

  test 'valid CSS' do
    dummy_object = DummyClass.new

    dummy_object.style = 'h1 { color: #fe12bc; }'

    assert dummy_object.valid?
  end

  test 'invalid CSS' do
    dummy_object = DummyClass.new

    dummy_object.style = 'h1 color: #fe12bc; }'

    assert_not dummy_object.valid?

    assert_equal(["undefined:1:21: missing '{'"], dummy_object.errors[:style])
  end
end
