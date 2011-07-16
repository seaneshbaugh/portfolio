class PostsController < ApplicationController
	def index
		@posts = Post.page(params[:page]).order("created_at asc")
	end

	def show
		@post = Post.find_by_slug(params[:id])
	end
end
