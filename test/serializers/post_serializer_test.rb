# frozen_string_literal: true

class PostSerializerTest < ActiveSupport::TestCase
  test "it serializes the post's title" do
    post = posts(:first_post)

    serializer = PostSerializer.new(post)

    assert_equal('First Post', serializer.serializable_hash.dig(:data, :attributes, :title))
  end

  test "it serializes the post's body" do
    post = posts(:first_post)

    serializer = PostSerializer.new(post)

    assert_equal('<p>My first post.</p>', serializer.serializable_hash.dig(:data, :attributes, :body))
  end
end
