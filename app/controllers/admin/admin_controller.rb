# frozen_string_literal: true

class Admin::AdminController < ApplicationController
  before_action :authenticate_user!

  layout 'admin'

  def index; end

  def authorize(record, query = nil)
    super([:admin, record], query)
  end

  def policy_scope(scope)
    super([:admin, scope])
  end
end
