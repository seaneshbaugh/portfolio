# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test 'should show a page' do
    page = pages(:about)

    get :show, params: { id: page }

    assert_response :ok
  end

  test 'should not show a page that does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, params: { id: 'does-not-exist' }
    end
  end
end
