# frozen_string_literal: true

module ApplicationHelper
  include ClassNames

  def cms_requires_full_reload?
    content = [ @page, @post, *@posts ].compact
    content.any? { |item| item.script.present? || item.body.to_s.match?(/<script\b/i) }
  end

  BUTTON_CLASSES = "inline-flex items-center justify-center gap-2 rounded-md px-3 py-2 text-sm font-medium shadow-xs focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-50".freeze

  def caution_button_class
    "#{BUTTON_CLASSES} bg-slate-700 text-white hover:bg-slate-800 focus-visible:outline-slate-600"
  end

  def error_messages_for(object)
    "#{object.errors.full_messages.uniq.join('. ')}."
  end

  def info_button_class
    "#{BUTTON_CLASSES} border border-slate-300 bg-white text-slate-700 hover:bg-slate-100 focus-visible:outline-slate-600"
  end

  def nav_link_to(*args, &block)
    body = block ? capture(&block) : args.shift

    path = args[0]

    html_options = args[1] || {}

    options = args[2] || {}

    NavLinkGenerator.new(request, body, path, html_options, options).to_html
  end

  def page_title(title)
    return t(".title") if title.blank?

    title.strip
  end

  def page_meta_description(meta_description)
    return t(".meta_description") if meta_description.blank?

    meta_description.strip
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize

    presenter = klass.new(object, self)

    yield presenter if block_given?

    presenter
  end

  def success_button_class
    "#{BUTTON_CLASSES} bg-blue-700 text-white hover:bg-blue-800 focus-visible:outline-blue-600"
  end

  def warning_button_class
    "#{BUTTON_CLASSES} bg-red-700 text-white hover:bg-red-800 focus-visible:outline-red-600"
  end

  def icon(name, **options)
    paths = {
      close: "M6 6l12 12M6 18L18 6",
      delete: "M4 7h16M10 3h4l1 4H9l1-4M6 7l1 14h10l1-14M10 11v6M14 11v6",
      edit: "M16 3l5 5-12 12-6 1 1-6L16 3M14 5l5 5",
      search: "M21 21l-6-6M17 10a7 7 0 11-14 0 7 7 0 0114 0",
      drag: "M5 8h14M5 12h14M5 16h14",
      plus: "M12 5v14M5 12h14",
      mail: "M3 5h18v14H3V5M3 5l9 7 9-7",
      external: "M14 3h7v7M10 14L21 3M21 14v7H3V3h7"
    }
    tag.svg(width: 20, height: 20, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 1.8,
      "stroke-linecap": "round", "stroke-linejoin": "round", class: "h-5 w-5 shrink-0",
      aria: { hidden: true }, focusable: false, **options) { tag.path(d: paths.fetch(name.to_sym)) }
  end

  def flash_messages
    render partial: "shared/flash_messages"
  end
end
