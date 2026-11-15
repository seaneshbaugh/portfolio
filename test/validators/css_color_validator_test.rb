# frozen_string_literal: true

require "test_helper"

class CssColorValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :color

    validates :color, css_color: true
  end

  class OptionalDummyClass < DummyClass
    clear_validators!

    validates :color, css_color: { allow_blank: true }
  end

  test "nil blank and non-string values produce validation errors" do
    [ nil, "", " ", 123, false, [], {} ].each do |color|
      object = DummyClass.new(color: color)

      assert_not object.valid?, "Expected #{color.inspect} to be invalid"
      assert_equal [ "is invalid" ], object.errors[:color]
    end
  end

  test "a valid line inside an invalid string does not match" do
    [ "#abcdef\n", "invalid\n#abcdef", "#abcdef\ninvalid", "#abc\n#def" ].each do |color|
      object = DummyClass.new(color: color)

      assert_not object.valid?, "Expected #{color.inspect} to be invalid"
      assert_equal [ "is invalid" ], object.errors[:color]
    end
  end

  test "supported hex and functional color formats remain valid" do
    [ "#abc", "#ABCD", "#abcdef", "#abcdef12", "rgb(255, 0, 0)", "rgba(255, 0, 0, 0.5)", "hsl(120, 50%, 50%)", "hsla(120, 50%, 50%, 0.5)" ].each do |color|
      assert DummyClass.new(color: color).valid?, "Expected #{color.inspect} to be valid"
    end
  end

  test "allow_blank continues to accept absent optional colors" do
    [ nil, "", " " ].each do |color|
      assert OptionalDummyClass.new(color: color).valid?
    end

    assert_not OptionalDummyClass.new(color: "invalid").valid?
  end

  test "valid RGB hex" do
    dummy_object = DummyClass.new

    dummy_object.color = "#abcdef"

    assert dummy_object.valid?
  end

  test "invalid RGB hex" do
    dummy_object = DummyClass.new

    dummy_object.color = "#1234567"

    assert_not dummy_object.valid?

    assert_equal([ "is invalid" ], dummy_object.errors[:color])
  end
end
