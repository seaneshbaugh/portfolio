# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user
  attr_reader :record

  def initialize(user, record)
    @user = user

    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record)
  end

  class Scope
    attr_reader :user
    attr_reader :scope

    def initialize(user, scope)
      @user = user

      @scope = scope
    end

    def resolve
      scope
    end
  end
end
