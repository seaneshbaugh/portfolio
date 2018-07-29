# frozen_string_literal: true

class PictureSerializer
  include FastJsonapi::ObjectSerializer

  set_type :picture

  attributes :slug, :title, :alt_text, :caption, :original_image_url, :medium_image_path, :thumbnail_image_url

  attribute :created_at do |object|
    object.created_at.to_s(:iso8601)
  end

  attribute :updated_at do |object|
    object.updated_at.to_s(:iso8601)
  end
end
