# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    @page = Page.published.friendly.find(params[:id])
  end
end
