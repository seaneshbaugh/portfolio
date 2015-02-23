class Admin::TagsController < Admin::AdminController
  def index
    @search = ActsAsTaggableOn::Tag.search(params[:q])

    @tags = @search.result

    render json: @tags.map { |tag| tag.name }.to_json
  end
end
