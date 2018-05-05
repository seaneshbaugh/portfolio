# frozen_string_literal: true

class Admin::AdminController < ApplicationController
  include ScopedPolicies

  before_action :authenticate_user!

  layout 'admin'

  def index; end
end
