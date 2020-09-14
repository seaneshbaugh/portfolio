# frozen_string_literal: true

require 'test_helper'

class CssColorValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :color

    validates :color, css_color: true
  end

  test 'valid RGB hex' do
    dummy_object = DummyClass.new

    dummy_object.color = '#abcdef'

    assert dummy_object.valid?
  end

  test 'invalid RGB hex' do
    dummy_object = DummyClass.new

    dummy_object.color = '#1234567'

    assert_not dummy_object.valid?

    assert_equal(['is invalid'], dummy_object.errors[:color])
  end
end
