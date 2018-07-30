# frozen_string_literal: true

module MetaContentable
  extend ActiveSupport::Concern

  included do
    delegate :content_for, to: :@template
  end

  def meta_content
    page_title_content

    meta_description_content
  end

  def meta_description_content
    return unless @object.meta_description.present?

    content_for :meta_description do
      @object.meta_description
    end
  end

  def page_title_content
    return unless @object.title.present?

    content_for :page_title do
      "#{@object.title.strip} - #{t('application.title')}"
    end
  end
end
