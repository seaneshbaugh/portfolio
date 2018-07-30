# frozen_string_literal: true

class PagePresenter < BasePresenter
  include FrontEnd
  include Linkable
  include MetaContentable

  delegate :contrast_color, to: :@template

  def initialize(page, template)
    super

    @page = page
  end

  def color_text
    content_tag(:span, @page.color, style: "background: #{@page.color}; color: #{contrast_color(@page.color)}; padding: 3px;") if @page.color.present?
  end

  def header_style
    "color: #{@page.color}" if @page.color.present?
  end

  def show_in_menu
    if @page.show_in_menu
      t('yes')
    else
      t('no')
    end
  end

  def visible
    if @page.visible
      t('yes')
    else
      t('no')
    end
  end

  private

  def base_path
    '/'
  end
end
