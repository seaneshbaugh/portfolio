# frozen_string_literal: true

class Admin::PagesController < Admin::AdminController
  before_action :set_page, only: %i[show edit update destroy]

  def index
    authorize Page

    @search = Page.search(params[:q])

    @pages = @search.result.page(params[:page]).per(25).by_order
  end

  def show
    authorize @page
  end

  def new
    authorize Page

    @page = Page.new
  end

  def edit
    authorize @page
  end

  def create
    authorize Page

    @page = Page.new(page_params)

    if @page.save
      flash[:success] = I18n.t('.success')

      redirect_to admin_page_url(@page)
    else
      flash.now[:error] = helpers.error_messages_for(@page)

      render 'new', status: 422
    end
  end

  def update
    if @page.update(page_params)
      flash[:success] = I18n.t('.success')

      redirect_to edit_admin_page_url(@page)
    else
      flash.now[:error] = helpers.error_messages_for(@page)

      render 'edit', status: 422
    end
  end

  def destroy
    @page.destroy

    flash[:success] = I18n.t('.success')

    redirect_to admin_pages_url
  end

  private

  def set_page
    @page = Page.friendly.find(params[:id])

    raise ActiveRecord::RecordNotFound if @page.nil?
  end

  def page_params
    params.require(:page).permit(:title, :body, :style, :script, :meta_description, :meta_keywords, :order, :color, :show_in_menu, :visible)
  end
end
