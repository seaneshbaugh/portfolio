# frozen_string_literal: true

module Admin
  class PicturesController < AdminController
    def index
      authorize Picture

      @search = Picture.ransack(params[:q])

      @pictures = @search.result.page(params[:page]).per(25).reverse_chronological

      # TODO: Consider moving this to a proper API with some sort of token based authentication.
      respond_to do |format|
        format.html

        format.json do
          render json: @pictures.map { |picture| PictureSerializer.new(picture).as_json }
        end
      end
    end

    def show
      @picture = find_picture

      authorize @picture
    end

    def new
      authorize Picture

      @picture = Picture.new
    end

    def create
      authorize Picture

      @picture = Picture.new(picture_params)

      respond_to do |format|
        if @picture.save
          format.html do
            flash[:success] = t('.success')

            redirect_to admin_picture_url(@picture), status: :see_other
          end

          format.json do
            render json: PictureSerializer.new(@picture).as_json
          end
        else
          format.html do
            flash.now[:error] = helpers.error_messages_for(@picture)

            render 'new', status: :unprocessable_entity
          end

          format.json do
            # TODO: Maybe put this in a helper? See http://jsonapi.org/format/#error-objects.
            render json: { errors: @picture.errors.map { |attribute, message| { title: "#{attribute.to_s.humanize} #{message}" } } }
          end
        end
      end
    end

    def edit
      @picture = find_picture

      authorize @picture
    end

    def update
      @picture = find_picture

      authorize @picture

      if @picture.update(picture_params)
        flash[:success] = t('.success')

        redirect_to edit_admin_picture_url(@picture), status: :see_other
      else
        flash.now[:error] = helpers.error_messages_for(@picture)

        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      @picture = find_picture

      authorize @picture

      @picture.destroy

      flash[:success] = t('.success')

      redirect_to admin_pictures_url, status: :see_other
    end

    def selector
      authorize Picture, :create

      @pictures = Picture.reverse_chronological

      render layout: false
    end

    private

    def find_picture
      Picture.friendly.find(params[:id])
    end

    def picture_params
      params.require(:picture).permit(:title, :alt_text, :caption, :image)
    end
  end
end
