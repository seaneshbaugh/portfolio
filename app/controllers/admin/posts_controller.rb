# frozen_string_literal: true

class Admin::PostsController < Admin::AdminController
  authorize_resource

  before_action :set_post, only: %i[show edit update destroy]

  def index
    @search = Post.search(params[:q])

    @posts = @search.result.page(params[:page]).per(25).reverse_chronological
  end

  def show; end

  def new
    @post = Post.new
  end

  def edit; end

  def create
    @post = Post.new(post_params)

    if !(current_user.sysadmin? || current_user.admin?) || @post.user.nil?
      @post.user = current_user
    end

    if @post.save
      flash[:success] = 'Post was successfully created.'

      redirect_to admin_post_url(@post)
    else
      flash[:error] = @post.errors.full_messages.uniq.join('. ') + '.'

      render 'new'
    end
  end

  def update
    if !current_user.sysadmin? && !current_user.admin? && @post.user != current_user
      flash[:error] = 'You cannot edit another user\'s posts.'

      redirect_to(admin_posts_url) && return
    end

    if @post.update(post_params)
      flash[:success] = 'Post was successfully updated.'

      redirect_to edit_admin_post_url(@post)
    else
      flash[:error] = @post.errors.full_messages.uniq.join('. ') + '.'

      render 'edit'
    end
  end

  def destroy
    if !current_user.sysadmin? && !current_user.admin? && @post.user != current_user
      flash[:error] = 'You cannot edit another user\'s posts.'

      redirect_to(admin_posts_url) && return
    end

    @post.destroy

    flash[:success] = 'Post was successfully deleted.'

    redirect_to admin_posts_url
  end

  private

  def set_post
    @post = Post.where(slug: params[:id]).first

    raise ActiveRecord::RecordNotFound if @post.nil?
  end

  def post_params
    params.require(:post).permit(:title, :body, :style, :script, :meta_description, :meta_keywords, :visible)
  end
end
