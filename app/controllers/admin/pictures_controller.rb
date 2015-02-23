class Admin::PicturesController < Admin::AdminController
  authorize_resource

  before_action :set_picture, only: [:show, :edit, :update, :destroy]

  def index
    @search = Picture.search(params[:q])

    @pictures = @search.result.page(params[:page]).per(25).reverse_chronological
  end

  def show
  end

  def new
    @picture = Picture.new
  end

  def edit
  end

  def create
    respond_to do |format|
      format.html do
        @picture = Picture.new(picture_params)

        if @picture.save
          flash[:success] = 'Picture was successfully created.'

          admin_picture_url(@picture)
        else
          flash[:error] = @picture.errors.full_messages.uniq.join('. ') + '.'

          render 'new'
        end
      end

      format.js do
        @picture = Picture.create(picture_params)
      end
    end
  end

  def update
    if @picture.update(picture_params)
      flash[:success] = 'Picture was successfully updated.'

      redirect_to edit_admin_picture_url(@picture)
    else
      flash[:error] = @picture.errors.full_messages.uniq.join('. ') + '.'

      render 'edit'
    end
  end

  def destroy
    @picture.destroy

    flash[:success] = 'Picture was successfully deleted.'

    redirect_to admin_pictures_url
  end

  def selector
    @pictures = Picture.reverse_chronological

    render layout: false
  end

  private

  def set_picture
    @picture = Picture.where(id: params[:id]).first

    fail ActiveRecord::RecordNotFound if @picture.nil?
  end

  def picture_params
    params.require(:picture).permit(:title, :alt_text, :caption, :image)
  end
end
