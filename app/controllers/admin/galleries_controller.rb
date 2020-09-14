# frozen_string_literal: true

module Admin
  class GalleriesController < AdminController
    def index
      authorize Gallery

      @search = Gallery.ransack(params[:q])

      @galleries = @search.result.page(params[:page]).per(25).by_order
    end

    def show
      @gallery = find_gallery

      authorize @gallery
    end

    def new
      authorize Gallery

      @gallery = Gallery.new
    end

    def create
      authorize Gallery

      @gallery = Gallery.new(gallery_params)

      if @gallery.save
        flash[:success] = t('.success')

        redirect_to admin_gallery_url(@gallery), status: :see_other
      else
        flash.now[:error] = helpers.error_messages_for(@gallery)

        render 'new', status: :unprocessable_entity
      end
    end

    def edit
      @gallery = find_gallery

      authorize @gallery
    end

    def update
      @gallery = find_gallery

      authorize @gallery

      if @gallery.update(gallery_params)
        flash[:success] = t('.success')

        redirect_to edit_admin_gallery_url(@gallery), status: :see_other
      else
        flash.now[:error] = helpers.error_messages_for(@gallery)

        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      @gallery = find_gallery

      authorize @gallery

      @gallery.destroy

      flash[:success] = t('.success')

      redirect_to admin_galleries_url, status: :see_other
    end

    private

    def find_gallery
      Gallery.friendly.eager_load(gallery_pictures: :picture).merge(GalleryPicture.by_order).merge(GalleryPicture.chronological).find(params[:id])
    end

    def gallery_params
      params.require(:gallery).permit(:name, :description, :order, :visible, gallery_pictures_attributes: %i[id picture_id order visible featured _destroy])
    end
  end
end
