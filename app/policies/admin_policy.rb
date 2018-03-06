# frozen_string_literal: true

class AdminPolicy
  attr_accessor :user

  def initialize(user, _)
    @user = user
  end

  def index?
    user.is_admin?
  end
end
