# frozen_string_literal: true

class PictureSerializerTest < ActiveSupport::TestCase
  setup do
    attach_images_to_pictures!
  end

  test "it serializes the picture's title" do
    picture = pictures(:conney)

    serializer = PictureSerializer.new(picture)

    assert_equal('Conney the Corgi', serializer.serializable_hash.dig(:data, :attributes, :title))
  end

  test "it serializes the picture's alt text" do
    picture = pictures(:conney)

    serializer = PictureSerializer.new(picture)

    assert_equal('Conney the Corgi', serializer.serializable_hash.dig(:data, :attributes, :alt_text))
  end

  test "it serializes the picture's caption" do
    picture = pictures(:conney)

    serializer = PictureSerializer.new(picture)

    assert_equal('Conney the Corgi', serializer.serializable_hash.dig(:data, :attributes, :caption))
  end

  test "it serializes the picture's original image URL" do
    picture = pictures(:conney)

    serializer = PictureSerializer.new(picture)

    assert_match(URI::DEFAULT_PARSER.make_regexp, serializer.serializable_hash.dig(:data, :attributes, :original_image_url))
  end
end
