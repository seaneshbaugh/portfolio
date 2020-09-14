# frozen_string_literal: true

require 'test_helper'

class PostPresenterTest < ActiveSupport::TestCase
  test '#first_image returns the first image in the post body' do
    post = Post.new

    post.body = <<~HTML
      <p><img src="http://test/first-image.jpg"></p>
      <p><img src="http://test/second-image.jpg"></p>"
    HTML

    post_presenter = PostPresenter.new(post, view_context)

    assert_equal('http://test/first-image.jpg', post_presenter.first_image)
  end
end
