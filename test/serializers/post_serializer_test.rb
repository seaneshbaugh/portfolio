# frozen_string_literal: true

class PostSerializerTest < ActiveSupport::TestCase
  test "it serializes the post's title" do
    post = posts(:first_post)

    serializer = PostSerializer.new(post)

    assert serializer.serializable_hash.dig(:data, :attributes, :title) == 'First Post'
  end

  test "it serializes the post's body" do
    post = posts(:first_post)

    serializer = PostSerializer.new(post)

    assert serializer.serializable_hash.dig(:data, :attributes, :body) == '<p>My first post.</p>'
  end
end
