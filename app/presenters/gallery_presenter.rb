# frozen_string_literal: true

class GalleryPresenter < ApplicationPresenter
  include FrontEnd
  include Linkable

  def initialize(gallery, template)
    super

    @gallery = gallery
  end

  # rubocop:disable Rails/OutputSafety
  def description_tag
    tag.div(@gallery.description.html_safe, class: 'description')
  end
  # rubocop:enable Rails/OutputSafety

  def visible
    if @gallery.visible
      t('yes')
    else
      t('no')
    end
  end

  private

  def gallery_path
    @template.picture_path(@gallery)
  end

  def link_text_method
    :title
  end

  def link_url_method
    :gallery_path
  end
end
