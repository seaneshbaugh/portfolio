require "test_helper"

class PublicationVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:about)
    @post = posts(:first_post)
    @gallery = galleries(:salt_plains)

    [ @page, @post, @gallery ].each { |record| record.update!(visible: false) }
  end

  test "anonymous visitors get 404 for hidden content by slug and numeric ID" do
    assert_hidden_content_not_found
  end

  test "signed-in users including admins get 404 on hidden public URLs" do
    [ users(:casie_clark), users(:sean_eshbaugh) ].each do |user|
      sign_in user

      assert_hidden_content_not_found

      sign_out user
    end
  end

  test "hidden content is absent from public navigation and listings" do
    attach_images_to_pictures!

    get root_path

    assert_response :ok
    assert_select "article#post-#{@post.slug}", count: 0
    assert_select "article#post-#{posts(:second_post).slug}", count: 1
    assert_select ".main-header-nav a[href=?]", page_path(@page), count: 0
    assert_select ".main-header-nav a[href=?]", page_path(pages(:resume)), count: 1

    get pictures_path

    assert_response :ok
    assert_select "a[href=?]", picture_path(@gallery), count: 0
  end

  test "the public posts API omits hidden posts" do
    get api_v1_posts_path, as: :json

    assert_response :ok

    ids = response.parsed_body.map { |post| post.fetch("data").fetch("id") }

    assert_not_includes ids, @post.id.to_s
    assert_includes ids, posts(:second_post).id.to_s
  end

  test "the sitemap omits hidden content" do
    get sitemap_path, as: :xml

    assert_response :ok
    document = Nokogiri::XML(response.body)
    paths = document.xpath("//*[local-name()='loc' or local-name()='lock']").map { |node| URI(node.text).path }

    [ page_path(@page), post_path(@post), picture_path(@gallery) ].each do |path|
      assert_not_includes paths, path
    end
    assert_includes paths, page_path(pages(:resume))
    assert_includes paths, post_path(posts(:second_post))
  end

  test "menu visibility does not hide a published page" do
    @page.update!(visible: true, show_in_menu: false)

    get root_path

    assert_select ".main-header-nav a[href=?]", page_path(@page), count: 0

    get page_path(@page)

    assert_response :ok
    assert_includes response.body, @page.body
  end

  test "admins can still view and edit hidden content through admin routes" do
    attach_images_to_pictures!

    sign_in users(:sean_eshbaugh)

    [ admin_page_path(@page), edit_admin_page_path(@page),
      admin_post_path(@post), edit_admin_post_path(@post),
      admin_gallery_path(@gallery), edit_admin_gallery_path(@gallery) ].each do |path|
      get path

      assert_response :ok
    end
  end

  test "a published gallery shows only its visible memberships" do
    attach_images_to_pictures!

    @gallery.update!(visible: true)

    gallery_pictures(:conney).update!(visible: false)

    get picture_path(@gallery)

    assert_response :ok
    assert_select "a.lightbox", count: 1
    assert_select "a.lightbox[data-title=?]", pictures(:conney).title, count: 0
    assert_select "a.lightbox[data-title=?]", pictures(:cowboy).title, count: 1

    get pictures_path

    assert_response :ok
    assert_select ".gallery-preview img[src=?]", pictures(:cowboy).medium_image_path, count: 1
  end

  private

  def assert_hidden_content_not_found
    [ page_path(@page), page_path(id: @page.id),
      post_path(@post), post_path(id: @post.id),
      api_v1_post_path(@post), api_v1_post_path(id: @post.id),
      picture_path(@gallery), picture_path(id: @gallery.id) ].each do |path|
      get path

      assert_response :not_found
    end
  end
end
