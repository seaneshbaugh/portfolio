# frozen_string_literal: true

require 'test_helper'

module Admin
  class AdminControllerTest < ActionController::TestCase
    setup do
      sign_in users(:sean_eshbaugh)
    end

    test 'should get the admin index' do
      get :index

      assert_response :ok
    end
  end
end
