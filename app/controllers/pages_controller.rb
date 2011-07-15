class PagesController < ApplicationController
	def index
		@pages = Page.all
	end

	def show
		@page = Page.find_by_slug(params[:id])
	end
end
