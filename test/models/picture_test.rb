# frozen_string_literal: true

require "test_helper"

class PictureTest < ActiveSupport::TestCase
  setup { @created_pictures = [] }

  teardown do
    @created_pictures.each do |picture|
      picture.image.purge if picture.persisted? && picture.image.attached?
    end
  end

  test "blank titles use the uploaded filename without its final extension" do
    [ nil, "   " ].each do |title|
      picture = create_uploaded_picture(title: title)

      assert_equal "A day.by the Lake", picture.reload.title
    end
  end

  test "an explicit title survives the filename fallback and later metadata edits" do
    picture = create_uploaded_picture(title: "A chosen display title")

    assert_equal "A chosen display title", picture.reload.title

    picture.update!(caption: "An updated caption")

    assert_equal "A chosen display title", picture.reload.title
  end

  test "should not be valid if no image is attached" do
    picture = Picture.new

    assert_not picture.valid?

    assert_includes(picture.errors[:image], I18n.t("activerecord.errors.models.picture.attributes.image.no_file_uploaded"))
  end

  private

  def create_uploaded_picture(title:)
    picture = Picture.new(title: title)

    @created_pictures << picture

    File.open(fixture_file_path("conney-the-corgi.jpg")) do |image|
      picture.image.attach(io: image, filename: "A day.by the Lake.JPG", content_type: "image/jpeg")

      picture.save!
    end

    picture
  end
end
