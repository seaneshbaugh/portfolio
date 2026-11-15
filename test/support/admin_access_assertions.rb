# frozen_string_literal: true

module AdminAccessAssertions
  private

  def prepare_admin_access_actor(user = nil)
    # Discard the admin login queued by each controller test's ordinary setup.
    Warden.test_reset!

    if user
      user.update!(password: "access-test-password")
      sign_in user
    end

    # Establish the session and finish Devise tracking before taking snapshots.
    get admin_account_path

    user ? assert_response(:ok) : assert_redirected_to(new_user_session_path)
  end

  def assert_admin_data_unchanged(record)
    counts = %w[Page Post Gallery GalleryPicture Picture Link User Role ActiveStorage::Blob ActiveStorage::Attachment PaperTrail::Version ActsAsTaggableOn::Tagging].map { |model| "#{model}.count" }

    assert_no_changes -> { record.reload.attributes } do
      assert_no_changes -> { record.is_a?(User) ? record.roles.order(:id).ids : nil } do
        assert_no_difference(counts) { yield }
      end
    end
  end
end
