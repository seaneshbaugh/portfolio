# frozen_string_literal: true

module FrontEnd
  extend ActiveSupport::Concern

  # rubocop:disable Rails/OutputSafety
  def body_tag
    tag.div(@object.body.html_safe, class: 'body-content')
  end

  def script_tag
    tag.script(@object.script.html_safe) if @object.script.present?
  end

  def style_tag
    tag.style(@object.style.html_safe) if @object.style.present?
  end
  # rubocop:enable Rails/OutputSafety
end
