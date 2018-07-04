# frozen_string_literal: true

class UserSerializerTest < ActiveSupport::TestCase
  test "it serializes the user's title" do
    user = users(:sean_eshbaugh)

    serializer = UserSerializer.new(user)

    assert serializer.serializable_hash.dig(:data, :attributes, :email) == 'sean@seaneshbaugh.com'
  end
end
