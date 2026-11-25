# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "missing authors produce association errors instead of database exceptions" do
    post = posts(:first_post)
    [ nil, -1 ].each do |user_id|
      post.user_id = user_id

      assert_not post.save
      assert post.errors.added?(:user, :blank)
    end
  end

  test "editing a post does not revalidate its persisted author" do
    post = posts(:first_post)

    post.user.first_name = ""

    assert post.update(body: "<p>Changed post content.</p>"), post.errors.full_messages.join(", ")
    assert_equal "Sean", post.user.reload.first_name
  end
end
