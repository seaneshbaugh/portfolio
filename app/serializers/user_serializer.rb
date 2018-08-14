# frozen_string_literal: true

class UserSerializer
  include FastJsonapi::ObjectSerializer

  set_type :user

  attributes :email, :first_name, :last_name

  attribute :created_at do |object|
    object.created_at.to_s(:iso8601)
  end

  attribute :updated_at do |object|
    object.updated_at.to_s(:iso8601)
  end
end
