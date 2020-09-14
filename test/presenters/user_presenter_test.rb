# frozen_string_literal: true

require 'test_helper'

class UserPresenterTest < ActiveSupport::TestCase
  test '#email_link returns a mailto link' do
    user = users(:sean_eshbaugh)

    user_presenter = UserPresenter.new(user, view_context)

    assert_equal('<a href="mailto:sean@seaneshbaugh.com"><i class="material-icons">email</i></a>', user_presenter.email_link)
  end
end
