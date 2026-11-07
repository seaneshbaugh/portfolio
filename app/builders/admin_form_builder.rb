# frozen_string_literal: true

class AdminFormBuilder < ActionView::Helpers::FormBuilder
  include ApplicationHelper

  delegate :capture, to: :@template
  delegate :label_tag, to: :@template
  delegate :link_to, to: :@template
  delegate :tag, to: :@template

  def ace_editor(method, options = {})
    mode = options.delete(:mode) || "text"

    theme = options.delete(:theme) || "github"

    tag.div(class: "ace-editor-field input-field", data: { controller: "ace-editor", action: "turbo:before-cache@document->ace-editor#disconnect", ace_editor_mode_value: mode, ace_editor_theme_value: theme }) do
      label = label(method)

      ace_editor = tag.div("", id: ace_editor_id_for(method), class: "ace-editor", data: { ace_editor_target: "editor" })

      text_area = text_area(method, options.merge(class: "value", data: (options[:data] || {}).merge(ace_editor_target: "input")))

      label + ace_editor + text_area
    end
  end

  def picture_inserter(method, options = {}, &block)
    button_class = options.delete(:class) || "btn btn-flat waves-effect waves-light blue lighten-3"

    button_text = if block
                    capture(&block)
    else
                    I18n.t("admin.pages.new.insert_picture")
    end

    target = options.delete(:target) || ace_editor_id_for(method)

    @template.render "shared/admin/picture_selector", button_class: button_class,
      button_text: button_text, editor_target: target, ready: false
  end

  # def tag_list(method, options = {})
  #   tags = (object.send(method) || []).join(',')

  #   suggestions = (options.delete(:suggestions) || []).join(',')

  #   tag.div('', class: 'taglist-container', data: { 'tags' => tags, 'suggestions' => suggestions, 'objectname' => object_name, 'method' => method.to_s })
  # end

  private

  def ace_editor_id_for(method)
    "#{object_name}_#{method}-editor"
  end
end
