require 'application_system_test_case'
require_relative '../support/system_test_uploads'

class PublicNavigationTest < ApplicationSystemTestCase
  include SystemTestUploads
  include ActiveJob::TestHelper

  test 'visitors navigate posts and CMS pages' do
    visit root_path

    click_link 'First Post'

    assert_current_path post_path(posts(:first_post))
    assert_text 'My first post.'

    within '.main-header-nav' do
      click_link 'About'
    end

    assert_current_path page_path(pages(:about))
    assert_text 'About me.'
    assert_no_link 'Admin'
  end

  test 'post tag filtering and pagination' do
    posts(:first_post).update!(tag_list: 'browser-tag')

    visit root_path(tag: 'browser-tag')

    assert_link 'First Post'
    assert_no_link 'Second Post'

    25.times do |index|
      Post.create!(user: users(:sean_eshbaugh), title: "Pagination post #{index}", body: '<p>Page content.</p>', visible: true)
    end

    visit root_path

    assert_selector '.post', count: 25

    click_link '2', href: '/?page=2'

    assert_selector '.post', count: 2
  end

  test 'visitors browse galleries and open the lightbox' do
    attach_images_to_pictures!

    gallery = galleries(:salt_plains)

    gallery.update!(visible: true)

    visit root_path

    within '.main-header-nav' do
      click_link 'Pictures'
    end

    click_link 'Salt Plains'

    assert_current_path picture_path(gallery)

    find('a.lightbox', match: :first).click

    assert_selector '.glightbox-container'
    assert_selector '.glightbox-container img'

    find('.gclose').click

    assert_no_selector '.glightbox-container'
  end

  test 'links support all year month and tag views' do
    links(:seaneshbaugh).update!(tag_list: 'browser-tag')

    visit links_path

    click_link '2021'

    assert_current_path '/links/2021'

    click_link 'February'

    assert_current_path '/links/2021/2'

    assert_link 'seaneshbaugh.com', href: 'https://seaneshbaugh.com/'

    visit links_path(tag: 'browser-tag')

    assert_link 'seaneshbaugh.com', href: 'https://seaneshbaugh.com/'
    assert_no_link 'Cowboy the Cowdog', href: links(:cowboythecowdog).url

    visit '/links/2021/3'

    assert_no_link 'seaneshbaugh.com', href: 'https://seaneshbaugh.com/'
  end

  test 'contact submissions remain intentionally disabled' do
    visit contact_path

    fill_in 'Name', with: 'Local visitor'
    fill_in 'Email', with: 'visitor@example.test'
    fill_in 'Subject', with: 'Disabled contact check'
    fill_in 'Body', with: 'This must not send mail.'

    assert_no_enqueued_jobs do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        find('input[type=submit]').click

        assert_text 'Thanks!'
      end
    end
  end
end
