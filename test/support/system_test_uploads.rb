module SystemTestUploads
  extend ActiveSupport::Concern

  included do
    setup do
      @existing_system_test_blob_ids = ActiveStorage::Blob.ids
    end

    teardown do
      # Database transactions roll back records, but not files written to disk.
      # Purge only blobs created by this test, including failed direct uploads.
      ActiveStorage::Blob.where.not(id: @existing_system_test_blob_ids).find_each do |blob|
        blob.attachments.destroy_all
        blob.purge
      end
    end
  end
end
