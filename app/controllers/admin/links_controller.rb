# frozen_string_literal: true

module Admin
  class LinksController < AdminController
    def index
      authorize Link

      @search = Link.ransack(params[:q])

      @links = @search.result.page(params[:page]).per(25).reverse_chronological
    end

    def show
      @link = find_link

      authorize @link
    end

    def new
      authorize Link

      @link = Link.new
    end

    def edit
      @link = find_link

      authorize @link
    end

    def create
      authorize Link

      @link = Link.new(link_params)

      if @link.save
        flash[:success] = t('.success')

        redirect_to admin_link_url(@link), status: :see_other
      else
        flash[:error] = helpers.error_messages_for(@link)

        render 'new', status: :unprocessable_entity
      end
    end

    def update
      @link = find_link

      authorize @link

      if @link.update(link_params)
        flash[:success] = t('.success')

        redirect_to edit_admin_link_url(@link), status: :see_other
      else
        flash[:error] = helpers.error_messages_for(@link)

        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      @link = find_link

      authorize @link

      @link.destroy

      flash[:success] = t('.success')

      redirect_to admin_links_url, status: :see_other
    end

    private

    def find_link
      Link.find(params[:id])
    end

    def link_params
      params.require(:link).permit(:text, :url, :description, :published_at, :visible, :tag_list)
    end
  end
end
