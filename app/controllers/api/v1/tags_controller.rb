# frozen_string_literal: true

module Api
  module V1
    class TagsController < ApiController
      def index
        @tags = ActsAsTaggableOn::Tag.all

        render json: @tags.map(&:name)
      end
    end
  end
end
