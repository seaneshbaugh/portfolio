# frozen_string_literal: true

class PicturesController < ApplicationController
  def index
    @galleries = Gallery.by_order.chronological.eager_load(gallery_pictures: { picture: { image_attachment: :blob } })
  end

  def show
    @gallery = Gallery.friendly.eager_load(gallery_pictures: { picture: { image_attachment: :blob } }).merge(GalleryPicture.published).merge(GalleryPicture.by_order).merge(GalleryPicture.chronological).find(params[:id])

    raise ActiveRecord::RecordNotFound if @gallery.nil?
  end
end
