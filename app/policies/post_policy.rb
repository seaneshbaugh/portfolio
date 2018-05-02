# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def update?
    user.has_role?(:admin) || record.user_id == user.id
  end
end
