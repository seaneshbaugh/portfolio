# frozen_string_literal: true

class Admin::TagsController < Admin::AdminController
  def index
    @search = ActsAsTaggableOn::Tag.ransack(params[:q])

    @tags = @search.result

    render json: @tags.map(:name).to_json
  end
end
