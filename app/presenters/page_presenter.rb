# frozen_string_literal: true

class PagePresenter < ApplicationPresenter
  include FrontEnd
  include Linkable
  include MetaContentable

  delegate :contrast_color, to: :@template

  def initialize(page, template)
    super

    @page = page
  end

  def color_text
    tag.span(@page.color, style: "background: #{@page.color}; color: #{contrast_color(@page.color)}; padding: 3px;") if @page.color.present?
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

  def link_text_method
    :title
  end

  def link_url_method
    :page_path
  end

  def page_path
    @template.page_path(@page)
  end
end
