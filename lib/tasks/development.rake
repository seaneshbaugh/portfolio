# frozen_string_literal: true

namespace :development do
  desc 'Add local sample content and disk attachments without overwriting existing records'
  task sample_data: :environment do
    abort 'Sample data is only available in development.' unless Rails.env.development?
    abort 'Sample data requires local disk storage.' unless ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::DiskService)

    author = User.find_or_create_by!(email: 'local-demo@example.test') do |user|
      user.first_name = 'Local'
      user.last_name = 'Demo'
      user.password = SecureRandom.hex(32)
    end

    Page.find_or_create_by!(title: 'Local Demo Page') do |page|
      page.body = '<p>Local sample content for checking the public CMS page.</p>'
      page.color = '#3e4ad9'
      page.order = 0
      page.visible = true
      page.show_in_menu = true
    end

    Post.find_or_create_by!(title: 'Local Demo Post') do |post|
      post.user = author
      post.body = '<p>Local sample content for checking posts and the RSS feed.</p>'
      post.visible = true
      post.tag_list = ['local-demo']
    end

    picture = Picture.find_by(title: 'Local Demo Picture')
    unless picture
      picture = Picture.new(title: 'Local Demo Picture', alt_text: 'Conney the corgi', caption: 'Local sample attachment')
      File.open(Rails.root.join('test/fixtures/files/conney-the-corgi.jpg')) do |file|
        picture.image.attach(io: file, filename: 'local-demo.jpg', content_type: 'image/jpeg')
        picture.save!
      end
    end

    gallery = Gallery.find_or_create_by!(name: 'Local Demo Gallery') do |record|
      record.description = '<p>Local sample gallery.</p>'
      record.order = 0
      record.visible = true
    end
    gallery.gallery_pictures.find_or_create_by!(picture: picture) do |record|
      record.order = 0
      record.visible = true
      record.featured = true
    end

    Link.find_or_create_by!(url: 'https://example.test/local-demo') do |link|
      link.text = 'Local Demo Link'
      link.description = 'Local sample link for checking date and tag filters.'
      link.published_at = Time.zone.local(2025, 5, 1, 12)
      link.visible = true
      link.tag_list = ['local-demo']
    end

    puts 'Local sample content is ready. The sample author has a random password and is not an admin.'
  end
end
