# frozen_string_literal: true

require "test_helper"

class ForeignKeysTest < ActiveSupport::TestCase
  test "database rejects dangling references when model validations are bypassed" do
    post = posts(:first_post)
    post.update!(tag_list: "foreign-key-test")
    blob = ActiveStorage::Blob.create!(key: "foreign-key-test", filename: "test.jpg", byte_size: 1, checksum: "test", service_name: "test")
    attachment = ActiveStorage::Attachment.create!(record: pictures(:conney), name: "image", blob: blob)

    checks = [
      -> { post.update_columns(user_id: -1) },
      -> { gallery_pictures(:conney).update_columns(gallery_id: -1) },
      -> { gallery_pictures(:conney).update_columns(picture_id: -1) },
      -> { attachment.update_columns(blob_id: -1) },
      -> { post.taggings.first.update_columns(tag_id: -1) },
      -> { connection.execute("INSERT INTO users_roles (user_id, role_id) VALUES (-1, #{roles(:admin).id})") },
      -> { connection.execute("INSERT INTO users_roles (user_id, role_id) VALUES (#{users(:sean_eshbaugh).id}, -1)") }
    ]

    checks.each do |write|
      assert_raises ActiveRecord::InvalidForeignKey do
        ApplicationRecord.transaction(requires_new: true) { write.call }
      end
    end
  end

  test "direct parent deletion cannot bypass dependent cleanup" do
    post = posts(:first_post)
    post.update!(tag_list: "protected-tag")

    [ users(:sean_eshbaugh), galleries(:salt_plains), pictures(:conney), roles(:admin), post.tags.sole ].each do |parent|
      assert_raises ActiveRecord::InvalidForeignKey do
        ApplicationRecord.transaction(requires_new: true) { parent.delete }
      end
    end
  end

  test "Rails user deletion cleans posts taggings and role links and preserves version history" do
    user = users(:sean_eshbaugh)
    post = posts(:first_post)
    post.update!(tag_list: "deleted-author")
    post_ids = user.posts.ids
    version_ids = post.versions.ids

    assert version_ids.any?

    user.destroy!

    assert_empty Post.where(id: post_ids)
    assert_empty ActsAsTaggableOn::Tagging.where(taggable_type: "Post", taggable_id: post_ids)
    assert_equal 0, connection.select_value("SELECT count(*) FROM users_roles WHERE user_id = #{user.id}")
    assert_equal version_ids.sort, PaperTrail::Version.where(id: version_ids).ids.sort
  end

  test "Rails gallery and picture deletion remove memberships without deleting the other parent" do
    gallery = galleries(:salt_plains)
    picture = pictures(:conney)
    gallery.destroy!

    assert_empty GalleryPicture.where(gallery_id: gallery.id)
    assert Picture.exists?(picture.id)

    other_gallery = Gallery.create!(name: "Surviving gallery")
    other_gallery.gallery_pictures.create!(picture: picture)

    picture.destroy!

    assert_empty GalleryPicture.where(picture_id: picture.id)
    assert Gallery.exists?(other_gallery.id)
  end

  test "Rails role and tag deletion clean their join records" do
    role = roles(:admin)
    role.destroy!

    assert_equal 0, connection.select_value("SELECT count(*) FROM users_roles WHERE role_id = #{role.id}")
    assert User.exists?(users(:sean_eshbaugh).id)

    post = posts(:first_post)
    post.update!(tag_list: "removable-tag")

    tag = post.tags.sole
    tag.destroy!

    assert_empty ActsAsTaggableOn::Tagging.where(tag_id: tag.id)
    assert Post.exists?(post.id)
  end

  test "attached blobs are protected and attachment deletion allows later blob purge" do
    blob = ActiveStorage::Blob.create!(key: "protected-blob", filename: "test.jpg", byte_size: 1, checksum: "test", service_name: "test")
    attachment = ActiveStorage::Attachment.create!(record: pictures(:conney), name: "image", blob: blob)

    assert_raises ActiveRecord::InvalidForeignKey do
      ApplicationRecord.transaction(requires_new: true) { ActiveStorage::Blob.where(id: blob.id).delete_all }
    end

    attachment.destroy!

    blob.purge

    assert_not ActiveStorage::Blob.exists?(blob.id)
  end

  private

  def connection
    ApplicationRecord.connection
  end
end
