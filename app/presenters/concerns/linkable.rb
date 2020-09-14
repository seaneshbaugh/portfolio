# frozen_string_literal: true

module Linkable
  extend ActiveSupport::Concern

  def link(options = {})
    link_to(@object.title, path, options)
  end

  def share_link(options = {})
    link_to(tag.i('open_in_browser', class: 'material-icons'), path, options)
  end

  def path
    "#{base_path}#{@object.slug}"
  end
end
