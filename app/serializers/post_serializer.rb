# frozen_string_literal: true

class PostSerializer
  include JSONAPI::Serializer

  set_type :post

  attributes :title, :body, :style, :script

  attribute :created_at do |object|
    object.created_at.to_s(:iso8601)
  end

  attribute :updated_at do |object|
    object.updated_at.to_s(:iso8601)
  end
end
