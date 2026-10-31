# frozen_string_literal: true

require "test_helper"

class AdminUpgradeTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:sean_eshbaugh)
    sign_in @admin
  end

  test "user links resolve friendly slugs" do
    member = users(:casie_clark)
    member.update!(slug: "upgrade-member")

    get admin_user_path(member)
    assert_response :ok

    get edit_admin_user_path(member)
    assert_response :ok
  end

  test "compound post search and author sorting remain usable" do
    Post.create!(user: @admin, title: "Upgrade Search Match", body: "<p>Unique upgrade search content.</p>")

    get admin_posts_path, params: { q: { body_or_style_cont: "Unique upgrade search", s: "user_last_name asc" } }

    assert_response :ok
    assert_select "tr.post", count: 1
    assert_select "a", text: "Upgrade Search Match"
  end

  test "admin lists accept their creation date sort" do
    attach_images_to_pictures!

    %w[posts pages pictures galleries links users].each do |resource|
      get "/admin/#{resource}", params: { q: { s: "created_at desc" } }

      assert_response :ok
    end
  end

  test "users can be filtered and sorted by role" do
    get admin_users_path, params: { q: { roles_name_eq: "admin", s: "roles_name asc" } }

    assert_response :ok
    assert_select "tr.user", count: 1
    assert_select "td.user-name", text: @admin.full_name
  end

  test "admin user edits preserve a blank password and save selected roles" do
    member = users(:casie_clark)
    member.update!(password: "existing-password")
    encrypted_password = member.encrypted_password

    patch admin_user_path(member), params: { user: {
      first_name: "Updated", password: "", password_confirmation: "", role_ids: [ roles(:admin).id ]
    } }

    assert_response :see_other
    assert_equal "Updated", member.reload.first_name
    assert_equal encrypted_password, member.encrypted_password
    assert member.has_role?(:admin)
  end

  test "account edits do not require a password change" do
    @admin.update!(password: "existing-password")
    sign_in @admin
    encrypted_password = @admin.encrypted_password

    patch admin_account_path, params: { account: { first_name: "Updated", password: "", password_confirmation: "" } }

    assert_response :see_other
    assert_equal "Updated", @admin.reload.first_name
    assert_equal encrypted_password, @admin.encrypted_password
  end

  test "deletion redirects with its translated success message" do
    link = Link.create!(text: "Upgrade Delete Check", url: "https://example.test/delete-check", published_at: Time.current)

    assert_difference "Link.count", -1 do
      delete admin_link_path(link)
    end

    assert_redirected_to admin_links_path
    assert_equal "Link was successfully deleted.", flash[:success]
  end

  test "new galleries save their nested picture selections" do
    attach_images_to_pictures!
    picture = Picture.first

    assert_difference "GalleryPicture.count", 1 do
      post admin_galleries_path, params: { gallery: {
        name: "Nested picture check", order: 0, visible: true,
        gallery_pictures_attributes: { "0" => { picture_id: picture.id, order: 0, featured: true, visible: true } }
      } }
    end

    assert_response :see_other
    gallery = Gallery.find_by!(name: "Nested picture check")
    assert_equal picture, gallery.gallery_pictures.first.picture
  end

  test "invalid galleries redisplay unsaved picture selections" do
    attach_images_to_pictures!

    post admin_galleries_path, params: { gallery: {
      name: "", order: 0, visible: true,
      gallery_pictures_attributes: { "0" => { picture_id: Picture.first.id, order: 0, featured: false, visible: true } }
    } }

    assert_response :unprocessable_entity
    assert_select ".gallery-pictures-container[data-gallerypictures]"
  end

  test "picture creation exposes JSON validation errors without a success response" do
    post admin_pictures_path, params: { picture: { title: "Missing image" } }, as: :json

    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").first.fetch("title").present?
  end
end
