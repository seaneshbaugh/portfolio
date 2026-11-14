# frozen_string_literal: true

class PicturesController < ApplicationController
  def index
    @galleries = Gallery.published.by_order.chronological.preload(cover_gallery_picture: { picture: { image_attachment: :blob } })
  end

  def show
    @gallery = Gallery.published.friendly.eager_load(gallery_pictures: { picture: { image_attachment: :blob } }).merge(GalleryPicture.published).merge(GalleryPicture.by_order).merge(GalleryPicture.chronological).find(params[:id])
  end
end
