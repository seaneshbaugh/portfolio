# frozen_string_literal: true

require 'test_helper'

class JavascriptValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :script

    validates :script, javascript: true
  end

  test 'valid JavaScript' do
    dummy_object = DummyClass.new

    dummy_object.script = 'console.log("test");'

    assert dummy_object.valid?
  end

  test 'invalid JavaScript on first line' do
    dummy_object = DummyClass.new

    dummy_object.script = 'function(x, y, { return x + y; }'

    assert_not dummy_object.valid?

    assert_equal(["SyntaxError: Function statements require a function name at line 1\n function(x, y, { return x + y; }\n^^^^^^^^"], dummy_object.errors[:script])
  end

  test 'invalid JavaScript on second line' do
    dummy_object = DummyClass.new

    dummy_object.script = "console.log(\"test\");\nfunction(x, y, { return x + y; }"

    assert_not dummy_object.valid?

    assert_equal(["SyntaxError: Function statements require a function name at line 2\n function(x, y, { return x + y; }\n^^^^^^^^"], dummy_object.errors[:script])
  end
end
