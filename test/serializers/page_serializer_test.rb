# frozen_string_literal: true

class PageSerializerTest < ActiveSupport::TestCase
  test "it serializes the page's title" do
    page = pages(:about)

    serializer = PageSerializer.new(page)

    assert_equal('About', serializer.serializable_hash.dig(:data, :attributes, :title))
  end

  test "it serializes the page's body" do
    page = pages(:about)

    serializer = PageSerializer.new(page)

    assert_equal('<p>About me.</p>', serializer.serializable_hash.dig(:data, :attributes, :body))
  end
end
