# frozen_string_literal: true

module Admin
  class PagesController < AdminController
    def index
      authorize Page

      @search = Page.ransack(params[:q])

      @pages = @search.result.page(params[:page]).per(25).by_order
    end

    def show
      @page = find_page

      authorize @page
    end

    def new
      authorize Page

      @page = Page.new
    end

    def create
      authorize Page

      @page = Page.new(page_params)

      if @page.save
        flash[:success] = t('.success')

        redirect_to admin_page_url(@page), status: :see_other
      else
        flash.now[:error] = helpers.error_messages_for(@page)

        render 'new', status: :unprocessable_entity
      end
    end

    def edit
      @page = find_page

      authorize @page
    end

    def update
      @page = find_page

      authorize @page

      if @page.update(page_params)
        flash[:success] = t('.success')

        redirect_to edit_admin_page_url(@page), status: :see_other
      else
        flash.now[:error] = helpers.error_messages_for(@page)

        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      @page = find_page

      authorize @page

      @page.destroy

      flash[:success] = t('.success')

      redirect_to admin_pages_url, status: :see_other
    end

    private

    def find_page
      Page.friendly.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :body, :style, :script, :meta_description, :order, :color, :show_in_menu, :visible)
    end
  end
end
