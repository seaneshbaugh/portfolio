# frozen_string_literal: true

module Admin
  class AdminPolicy
    attr_accessor :user

    def initialize(user, _)
      @user = user
    end

    def index?
      user.has_role?(:admin)
    end

    def show?
      return false unless user.has_role?(:admin)

      case record
      when Class
        true
      else
        scope.where(id: record.id).exists?
      end
    end

    def create?
      user.has_role?(:admin)
    end
  end
end
