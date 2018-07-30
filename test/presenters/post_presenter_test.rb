# frozen_string_literal: true

class PostPresenterTest < ActiveSupport::TestCase
  test '#first_image returns the first image in the post body' do
    post = Post.new

    post.body = <<~BODY
      <p><img src="http://test/first-image.jpg"></p>
      <p><img src="http://test/second-image.jpg"></p>"
    BODY

    post_presenter = PostPresenter.new(post, view_context)

    assert post_presenter.first_image == 'http://test/first-image.jpg'
  end

  def view_context
    ActionView::Base.new(ActionController::Base.view_paths, {}, ActionController::Base.new)
  end
end
