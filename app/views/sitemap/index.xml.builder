# frozen_string_literal: true

xml.instruct!
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url do
    lastmod = if @posts.present?
                @posts.first.updated_at.xmlschema
              else
                Time.zone.now.beginning_of_month.xmlschema
              end

    changefreq = if @posts.present? && @posts.first.updated_at > Time.zone.now - 1.year
                   'monthly'
                 else
                   'yearly'
                 end

    xml.loc root_url
    xml.lastmod lastmod
    xml.changefreq changefreq
  end

  @pages.each do |page|
    xml.url do
      changefreq = if page.updated_at > Time.zone.now - 1.year
                     'monthly'
                   else
                     'yearly'
                   end

      xml.loc "#{root_url}#{page.slug}"
      xml.lastmod page.updated_at.xmlschema
      xml.changefreq changefreq
    end
  end

  @posts.each do |post|
    xml.url do
      changefreq = if post.updated_at > Time.zone.now - 1.year
                     'monthly'
                   else
                     'yearly'
                   end

      xml.loc post_url(post)
      xml.lastmod post.updated_at.xmlschema
      xml.changefreq changefreq
    end
  end

  xml.url do
    lastmod = if @galleries.present?
                @galleries.first.updated_at.xmlschema
              else
                Time.zone.now.beginning_of_month.xmlschema
              end

    changefreq = if @galleries.present? && @galleries.first.updated_at > Time.zone.now - 1.year
                   'monthly'
                 else
                   'yearly'
                 end

    xml.loc pictures_url
    xml.lastmod lastmod
    xml.changefreq changefreq
  end

  @galleries.each do |gallery|
    xml.url do
      changefreq = if gallery.updated_at > Time.zone.now - 1.year
                     'monthly'
                   else
                     'yearly'
                   end

      xml.lock picture_url(gallery)
      xml.lastmod gallery.updated_at.xmlschema
      xml.changefreq changefreq
    end
  end
end
