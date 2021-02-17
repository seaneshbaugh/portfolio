# frozen_string_literal: true

module Linkable
  extend ActiveSupport::Concern

  def base_path
    '/'
  end

  def link(options = {})
    link_to(send(link_text_method), send(link_url_method), options)
  end

  def share_link(options = {})
    link_to(tag.i('open_in_browser', class: 'material-icons'), send(link_url_method), options)
  end
end
