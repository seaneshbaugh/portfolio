# frozen_string_literal: true

class SitemapController < ApplicationController
  def index
    @pages = Page.published.select(:id, :slug, :updated_at).by_order

    @posts = Post.published.select(:id, :slug, :updated_at).reverse_chronological

    @galleries = Gallery.published.select(:id, :slug, :updated_at).reverse_chronological

    respond_to do |format|
      format.xml do
        render layout: false

        headers["Content-Type"] = "application/xml"
      end
    end
  end
end
