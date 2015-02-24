class PostPresenter < BasePresenter
  include Linkable

  def initialize(post, template)
    super

    @post = post
  end

  def user_full_name
    @post.user.full_name
  end

  private

  def base_path
    '/posts/'
  end
end
