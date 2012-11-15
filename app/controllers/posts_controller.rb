class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.where(:slug => params[:id]).first

    if @post.nil?
      flash[:error] = t('messages.posts.could_not_find')

      redirect_to root_url
    end
  end
end
