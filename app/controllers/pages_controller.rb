class PagesController < ApplicationController
	def index
	end

	def show
		@page = Page.find_by_slug(params[:id])
	end
end
