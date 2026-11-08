# frozen_string_literal: true

require "test_helper"

class UserPresenterTest < ActiveSupport::TestCase
  test "#email_link returns a mailto link" do
    user = users(:sean_eshbaugh)
    user_presenter = UserPresenter.new(user, view_context.extend(ApplicationHelper))
    link = Nokogiri::HTML.fragment(user_presenter.email_link).at_css("a")

    assert_equal "mailto:sean@seaneshbaugh.com", link["href"]
    assert_equal "Email sean@seaneshbaugh.com", link["aria-label"]
    assert link.at_css("svg[aria-hidden=true]")
  end
end
