# frozen_string_literal: true

class GalleryPictureSerializer
  include JSONAPI::Serializer

  set_type :gallery_picture

  attributes :gallery_id, :picture_id, :order, :visible, :featured

  attribute :created_at do |object|
    object.created_at.to_s(:iso8601)
  end

  attribute :updated_at do |object|
    object.updated_at.to_s(:iso8601)
  end

  attribute :picture_original_image_path do |object|
    object.picture.original_image_path
  end

  attribute :picture_original_image_url do |object|
    object.picture.original_image_url
  end

  attribute :picture_medium_image_path do |object|
    object.picture.medium_image_path
  end

  attribute :picture_medium_image_url do |object|
    object.picture.medium_image_url
  end

  attribute :picture_thumbnail_image_path do |object|
    object.picture.thumbnail_image_path
  end

  attribute :picture_thumbnail_image_url do |object|
    object.picture.thumbnail_image_url
  end
end
