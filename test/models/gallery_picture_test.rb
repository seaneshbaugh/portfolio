# frozen_string_literal: true

require "test_helper"

class GalleryPictureTest < ActiveSupport::TestCase
  test "missing gallery and picture references produce association errors" do
    [ :gallery, :picture ].each do |association|
      [ nil, -1 ].each do |id|
        membership = gallery_pictures(:conney)

        membership.public_send("#{association}_id=", id)

        assert_not membership.save
        assert membership.errors.added?(association, :blank)

        membership.reload
      end
    end
  end

  test "membership edits do not revalidate the persisted gallery" do
    membership = gallery_pictures(:conney)

    membership.gallery.name = ""

    assert membership.update(visible: false), membership.errors.full_messages.join(", ")
    assert_equal "Salt Plains", membership.gallery.reload.name
  end

  test "new galleries save nested memberships through their inverse association" do
    gallery = Gallery.new(name: "Nested gallery", gallery_pictures_attributes: [ { picture_id: pictures(:conney).id } ])

    assert gallery.save, gallery.errors.full_messages.join(", ")
    assert_equal gallery.id, gallery.gallery_pictures.sole.reload.gallery_id
  end

  test "invalid nested references reject the gallery and retain entered attributes" do
    gallery = Gallery.new(name: "Invalid nested gallery", gallery_pictures_attributes: [ { picture_id: -1 } ])

    assert_no_difference [ "Gallery.count", "GalleryPicture.count" ] do
      assert_not gallery.save
    end

    assert gallery.errors.any?
    assert_equal "Invalid nested gallery", gallery.name
    assert_equal(-1, gallery.gallery_pictures.first.picture_id)
  end
end
