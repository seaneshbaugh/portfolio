# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApiController
      def index
        @posts = Post.published

        render json: @posts.map { |post| PostSerializer.new(post) }
      end

      def show
        @post = Post.friendly.find(params[:id])

        render json: PostSerializer.new(@post)
      end
    end
  end
end
