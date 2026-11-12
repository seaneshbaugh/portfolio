# frozen_string_literal: true

module Admin
  class DirectUploadsController < ActiveStorage::DirectUploadsController
    include Pundit::Authorization

    before_action :authenticate_user!
    before_action :authorize_upload

    private

    def authorize_upload
      authorize [ :admin, Picture ], :create?
    end
  end
end
