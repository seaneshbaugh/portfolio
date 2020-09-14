# frozen_string_literal: true

require 'test_helper'

class PictureTest < ActiveSupport::TestCase
  # TODO: Extract this to a stand alone test for ImageAttachmentValidator.
  test 'should not be valid if no image is attached' do
    picture = Picture.new

    assert_not picture.valid?

    assert_includes(picture.errors[:image], I18n.t('activerecord.errors.models.picture.attributes.image.no_file_uploaded'))
  end
end
