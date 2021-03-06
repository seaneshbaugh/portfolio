# frozen_string_literal: true

class PostPresenter < ApplicationPresenter
  include FrontEnd
  include Linkable
  include MetaContentable

  def initialize(post, template)
    super

    @post = post
  end

  def created_at(format = nil)
    return unless @post.created_at

    if format
      @post.created_at.strftime(format)
    else
      super()
    end
  end

  def first_image
    images = Nokogiri::HTML(@post.body).xpath('//img')

    images[0]['src'] unless images.empty?
  end

  # rubocop:disable Rails/OutputSafety
  def more(truncate = true)
    if truncate && truncated?
      body_content = @post.body[0..@post.body.index('<!--more-->') - 1]

      body_content_class = 'body-content truncated'

      body_content_tag = tag.div(body_content.html_safe, class: body_content_class)

      body_content_tag + more_link
    else
      body_tag
    end
  end
  # rubocop:enable Rails/OutputSafety

  def more_link
    return unless truncated?

    tag.div(link_to(t('posts.index.read_more'), @post), class: 'read-more')
  end

  # rubocop:disable Rails/OutputSafety
  def tag_links
    @post.tag_list.map { |tag| link_to(tag, root_path(tag: tag)) }.join(', ').html_safe
  end
  # rubocop:enable Rails/OutputSafety

  def tag_list
    @post.tag_list.join(', ')
  end

  def truncated?
    @post.body.include?('<!--more-->')
  end

  def updated_at(format = nil)
    return unless @post.updated_at

    if format
      @post.updated_at.strftime(format)
    else
      super()
    end
  end

  def user_full_name
    @post.user.full_name
  end

  private

  def link_text_method
    :title
  end

  def link_url_method
    :post_path
  end

  def post_path
    @template.post_path(@post)
  end
end
