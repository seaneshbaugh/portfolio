# frozen_string_literal: true

module Api
  module V1
    class PicturesController < ApiController
      def index
        @pictures = Picture.page(params[:page]).per(25).reverse_chronological

        render json: @pictures.map { |picture| PictureSerializer.new(picture) }
      end

      def show
        @picture = Picture.friendly.find(params[:id])

        render json: PictureSerializer.new(@picture)
      end
    end
  end
end
