class PictureSerializer
  include FastJsonapi::ObjectSerializer

  set_type :picture

  attributes :title, :alt_text, :caption, :original_image_url
end
