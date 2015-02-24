class AceBuilder < BootstrapForm::FormBuilder
  include ApplicationHelper

  delegate :content_tag, to: :@template
  delegate :label_tag, to: :@template
  delegate :link_to, to: :@template

  def ace_editor(method, options = {})
    mode = options.delete(:mode) || 'text'

    form_group_builder(method, options) do
      text_area = text_area_without_bootstrap(method, options)

      ace_editor = content_tag(:div, '', id: ace_editor_id_for(method), class: 'ace-editor', data: { 'mode' => mode })

      text_area + ace_editor
    end
  end

  def picture_inserter(method, options = {}, &block)
    # render partial: 'shared/admin/picture_inserter', locals { target: ace_editor_id_for(method) }

    link_body = block_given? ? capture(&block) : 'Insert Picture'

    link_class = options.delete(:class) || 'btn btn-default'

    modal_id = "#{self.object_name}_#{method.to_s}-picture-selector-modal"

    form_group_builder(method, options.merge(skip_label: true)) do
      link = link_to(link_body, '/admin/pictures/selector', class: link_class, data: { toggle: 'modal', target: "\##{modal_id}" })

      modal = content_tag(:div, '', id: modal_id, class: 'modal fade', role: 'dialog', data: { target: ace_editor_id_for(method) })

      link + modal
    end

    # <div class="form-group" style="margin-bottom: 0; margin-top: 0;">
    #   <div class="col-lg-offset-2 col-lg-10">
    #     <a href="/admin/pictures/selector" class="btn btn-default" data-toggle="modal" data-target="#picture-selector-modal">Insert Picture</a>
    #     <div id="picture-selector-modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="pictureSelectorModal" aria-hidden="true" data-target="<%= target %>"></div>
    #   </div>
    # </div>

  end

  def ace_editor_id_for(method)
    "#{self.object_name}_#{method.to_s}-editor"
  end
end
