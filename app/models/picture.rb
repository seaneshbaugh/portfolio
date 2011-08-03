class Picture < ActiveRecord::Base
  attr_accessible :title, :alt_text, :caption, :image

  mount_uploader :image, ImageUploader

  def self.search(search)
    if search
      #where("title LIKE ?", "%#{search}%")
      where("title LIKE :search OR alt_text LIKE :search OR caption LIKE :search", { :search => "%#{search}%" })
    else
      scoped
    end
  end
end
