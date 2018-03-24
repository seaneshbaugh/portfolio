# frozen_string_literal: true

class Admin::AdminController < ApplicationController
  before_filter :authenticate_user!

  layout 'admin'

  def index; end
end
