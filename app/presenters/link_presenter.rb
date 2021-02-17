# frozen_string_literal: true

class LinkPresenter < ApplicationPresenter
  include Linkable

  def initialize(link, template)
    super

    @link = link
  end

  # rubocop:disable Rails/OutputSafety
  def tag_links(base_path)
    @link.tags.map { |tag| link_to(tag, "#{base_path}?tag=#{tag}") }.join(', ').html_safe
  end
  # rubocop:enable Rails/OutputSafety

  def tag_list
    @link.tags.join(', ')
  end

  private

  def link_text_method
    :text
  end

  def link_url_method
    :url
  end
end
