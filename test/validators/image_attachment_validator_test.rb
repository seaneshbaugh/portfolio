# frozen_string_literal: true

require 'test_helper'

class ImageAttachmentValidatorTest < ActiveSupport::TestCase
  test 'image attached' do
    picture = Picture.new

    picture.image.attach(io: File.open(fixture_file_path('cowboy-the-cowdog.jpg')), filename: 'cowboy-the-cowdog.jpg')

    assert picture.valid?
  end

  test 'no image attached' do
    picture = Picture.new

    assert_not picture.valid?

    assert_equal(['no file uploaded'], picture.errors[:image])
  end
end
