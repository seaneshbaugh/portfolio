# frozen_string_literal: true

class AdminFormBuilder < ActionView::Helpers::FormBuilder
  include ApplicationHelper

  INPUT_CLASSES = "block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-xs focus:border-blue-600 focus:outline-2 focus:outline-blue-600".freeze

  %i[text_field email_field password_field number_field url_field date_field telephone_field text_area].each do |field_type|
    define_method(field_type) do |method, options = {}|
      super(method, styled_options(options, INPUT_CLASSES))
    end
  end

  def file_field(method, options = {})
    super(method, styled_options(options, "block w-full rounded-md border border-slate-300 p-2 text-sm file:mr-3 file:rounded file:border-0 file:bg-slate-100 file:px-3 file:py-2 file:text-slate-700"))
  end

  def color_field(method, options = {})
    super(method, styled_options(options, "block h-10 w-20 rounded-md border border-slate-300 bg-white p-1"))
  end

  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    super(method, styled_options(options, "h-4 w-4 rounded border-slate-300 accent-blue-700 focus:outline-2 focus:outline-blue-600"), checked_value, unchecked_value)
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    super(method, choices, options, styled_options(html_options, INPUT_CLASSES), &block)
  end

  def label(method, text = nil, options = {}, &block)
    classes = block ? "inline-flex items-center gap-2 text-sm font-medium text-slate-700" : "block text-sm font-medium text-slate-700"
    super(method, text, styled_options(options, classes), &block)
  end

  def ace_editor(method, options = {})
    mode = options.delete(:mode) || "text"
    theme = options.delete(:theme) || "github"
    @template.tag.div(class: "ace-editor-field space-y-2", data: { controller: "ace-editor", action: "turbo:before-cache@document->ace-editor#disconnect", ace_editor_mode_value: mode, ace_editor_theme_value: theme }) do
      label(method) +
        @template.tag.div("", id: ace_editor_id_for(method), class: "ace-editor overflow-hidden rounded-md border border-slate-300", data: { ace_editor_target: "editor" }) +
        text_area(method, options.merge(hidden: true, class: "value hidden", data: (options[:data] || {}).merge(ace_editor_target: "input")))
    end
  end

  def picture_inserter(method, options = {}, &block)
    @template.render "shared/admin/picture_selector", button_class: options.delete(:class) || info_button_class,
      button_text: block ? @template.capture(&block) : I18n.t("admin.pages.new.insert_picture"),
      editor_target: options.delete(:target) || ace_editor_id_for(method), ready: false
  end

  private

  def styled_options(options, classes)
    options.merge(class: [ classes, options[:class] ].compact.join(" "))
  end

  def ace_editor_id_for(method)
    "#{object_name}_#{method}-editor"
  end
end
