class Post < ActiveRecord::Base
	has_paper_trail

	belongs_to :user

	validates_uniqueness_of :title

	validates_presence_of :title, :body

	before_save :create_slug

	def to_param
		self.slug
	end

	def create_slug
		if self.title.blank?
			self.slug = self.id
		else
			self.slug = self.title.parameterize
		end
	end
end
