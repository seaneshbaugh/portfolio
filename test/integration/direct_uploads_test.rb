require "test_helper"
require "digest"

class DirectUploadsTest < ActionDispatch::IntegrationTest
  test "anonymous requests cannot allocate blobs at the standard upload URLs" do
    [ rails_direct_uploads_path, rails_direct_uploads_path(format: :json) ].each do |path|
      assert_no_difference [ "ActiveStorage::Blob.count", "ActiveStorage::Attachment.count", "Picture.count" ] do
        post path, params: upload_params, as: :json
      end

      assert_response :unauthorized
      assert_not response.parsed_body.key?("signed_id")
      assert_not response.parsed_body.key?("direct_upload")
    end
  end

  test "signed-in non-admins cannot allocate blobs" do
    sign_in users(:casie_clark)

    assert_no_difference [ "ActiveStorage::Blob.count", "ActiveStorage::Attachment.count", "Picture.count" ] do
      post rails_direct_uploads_path, params: upload_params, as: :json
    end

    assert_response :forbidden
  end

  test "admins receive the standard direct upload response" do
    sign_in users(:sean_eshbaugh)

    assert_difference "ActiveStorage::Blob.count", 1 do
      assert_no_difference [ "ActiveStorage::Attachment.count", "Picture.count" ] do
        post rails_direct_uploads_path, params: upload_params, as: :json
      end
    end

    assert_response :ok

    result = response.parsed_body
    blob = ActiveStorage::Blob.find_signed!(result.fetch("signed_id"))

    assert_equal "direct-upload.txt", blob.filename.to_s
    assert_equal upload_params[:blob][:checksum], blob.checksum
    assert_equal 5, blob.byte_size
    assert result.fetch("direct_upload").fetch("url").present?
    assert_kind_of Hash, result.fetch("direct_upload").fetch("headers")
  end

  test "a valid public CSRF token does not grant anonymous upload access" do
    with_forgery_protection do
      get root_path

      token = Nokogiri::HTML(response.body).at_css('meta[name="csrf-token"]')["content"]

      assert_no_difference "ActiveStorage::Blob.count" do
        post rails_direct_uploads_path, params: upload_params, headers: { "X-CSRF-Token" => token }, as: :json
      end

      assert_response :unauthorized
    end
  end

  test "admin uploads still require CSRF protection" do
    sign_in users(:sean_eshbaugh)

    with_forgery_protection do
      assert_no_difference "ActiveStorage::Blob.count" do
        post rails_direct_uploads_path, params: upload_params, as: :json
      end

      assert_response :unprocessable_entity
    end
  end

  test "admins can upload with a valid CSRF token" do
    sign_in users(:sean_eshbaugh)

    with_forgery_protection do
      get root_path

      token = Nokogiri::HTML(response.body).at_css('meta[name="csrf-token"]')["content"]

      assert_difference "ActiveStorage::Blob.count", 1 do
        post rails_direct_uploads_path, params: upload_params, headers: { "X-CSRF-Token" => token }, as: :json
      end

      assert_response :ok
      assert response.parsed_body.fetch("signed_id").present?
    end
  end

  test "signed blob read routes remain available without signing in" do
    picture = pictures(:conney)

    picture.image.attach(io: File.open(fixture_file_path("conney-the-corgi.jpg")), filename: "conney.jpg", content_type: "image/jpeg")

    blob = picture.image.blob

    get rails_service_blob_path(blob.signed_id, blob.filename)

    assert_response :redirect
    assert_match "/rails/active_storage/disk/", response.location
  ensure
    blob&.purge
  end

  private

  def upload_params
    { blob: { filename: "direct-upload.txt", byte_size: 5, checksum: Digest::MD5.base64digest("probe"), content_type: "text/plain" } }
  end

  def with_forgery_protection
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = original
  end
end
