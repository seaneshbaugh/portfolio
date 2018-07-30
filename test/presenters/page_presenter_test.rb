# frozen_string_literal: true

require 'test_helper'

class PagePresenterTest < ActiveSupport::TestCase
  test '#color_text returns a span with style' do
    page = Page.new

    page.color = '#ffffff'

    page_presenter = PagePresenter.new(page, view_context)

    assert page_presenter.color_text == '<span style="background: #ffffff; color: #000000; padding: 3px;">#ffffff</span>'
  end

  test '#header_style returns the color style for page headers' do
    page = Page.new

    page.color = '#ffffff'

    page_presenter = PagePresenter.new(page, view_context)

    assert page_presenter.header_style == 'color: #ffffff'
  end

  def view_context
    view_context = ActionView::Base.new(ActionController::Base.view_paths, {}, ActionController::Base.new)

    view_context.extend(PagesHelper)

    view_context
  end
end
