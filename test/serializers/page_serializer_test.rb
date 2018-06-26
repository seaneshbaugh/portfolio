# frozen_string_literal: true

class PageSerializerTest < ActiveSupport::TestCase
  test "it serializes the page's title" do
    page = pages(:about)

    serializer = PageSerializer.new(page)

    assert serializer.serializable_hash.dig(:data, :attributes, :title) == 'About'
  end

  test "it serializes the page's body" do
    page = pages(:about)

    serializer = PageSerializer.new(page)

    assert serializer.serializable_hash.dig(:data, :attributes, :body) == '<p>About me.</p>'
  end
end
