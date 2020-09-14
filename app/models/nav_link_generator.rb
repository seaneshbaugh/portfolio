# frozen_string_literal: true

class NavLinkGenerator
  include ActionView::Helpers::UrlHelper

  def initialize(request, body, path, html_options, options)
    @request = request

    @body = body

    @path = path

    @html_options = html_options

    @options = options
  end

  # rubocop:disable Rails/OutputSafety
  def to_html
    html = link

    html = content_tag(@options[:wrapper], html, class: wrapper_classes) if @options[:wrapper]

    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  private

  def link
    link_to(@body, @path, html_options)
  end

  def html_options
    active? ? @html_options.merge(class: link_classes) : @html_options
  end

  def active?
    segments = @options[:segments] || 1

    @request.path.split('/').reject(&:blank?).first(segments) == @path.split('/').reject(&:blank?).first(segments)
  end

  def link_classes
    if @html_options[:class]
      @html_options[:class].split(' ').push(active_class).join(' ')
    elsif !@options[:wrapper]
      active_class
    end
  end

  def active_class
    @options[:active_class] || 'active'
  end

  def wrapper_classes
    if active?
      if @options[:wrapper_class].blank?
        active_class
      else
        @options[:wrapper_class].split(' ').push(active_class).join(' ')
      end
    else
      @options[:wrapper_class]
    end
  end
end
