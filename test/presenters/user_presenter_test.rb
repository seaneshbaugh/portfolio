# frozen_string_literal: true

class UserPresenterTest < ActiveSupport::TestCase
  test '#email_link returns a mailto link' do
    user = users(:sean_eshbaugh)

    user_presenter = UserPresenter.new(user, view_context)

    assert user_presenter.email_link == '<a href="mailto:sean@seaneshbaugh.com"><i class="material-icons">email</i></a>'
  end

  def view_context
    ActionView::Base.new(ActionController::Base.view_paths, {}, ActionController::Base.new)
  end
end
