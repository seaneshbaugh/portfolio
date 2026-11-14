# frozen_string_literal: true

module Api
  module V1
    class TagsController < ApiController
      def index
        @tags = ActsAsTaggableOn::Tag.pluck(:name)

        render json: @tags
      end
    end
  end
end
