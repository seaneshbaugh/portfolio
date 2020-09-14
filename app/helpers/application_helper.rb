# frozen_string_literal: true

module ApplicationHelper
  include ClassNames

  def caution_button_class
    'btn btn-flat waves-effect waves-light yellow darken-3'
  end

  def error_messages_for(object)
    "#{object.errors.full_messages.uniq.join('. ')}."
  end

  def info_button_class
    'btn btn-flat waves-effect waves-light blue darken-3'
  end

  def nav_link_to(*args, &block)
    body = block_given? ? capture(&block) : args.shift

    path = args[0]

    html_options = args[1] || {}

    options = args[2] || {}

    NavLinkGenerator.new(request, body, path, html_options, options).to_html
  end

  def page_title(title)
    return t('.title') if title.blank?

    title.strip
  end

  def page_meta_description(meta_description)
    return t('.meta_description') if meta_description.blank?

    meta_description.strip
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize

    presenter = klass.new(object, self)

    yield presenter if block_given?

    presenter
  end

  def success_button_class
    'btn btn-flat waves-effect waves-light green darken-3'
  end

  def warning_button_class
    'btn btn-flat waves-effect waves-light red darken-3'
  end

  def flash_messages
    render partial: 'shared/flash_messages'
  end
end
