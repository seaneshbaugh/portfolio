# frozen_string_literal: true

class GalleryPresenter < BasePresenter
  include FrontEnd
  include Linkable

  def initialize(gallery, template)
    super

    @gallery = gallery
  end

  # rubocop:disable Rails/OutputSafety
  def description_tag
    tag.div(@object.description.html_safe, class: 'description')
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

  def base_path
    '/pictures/'
  end
end
