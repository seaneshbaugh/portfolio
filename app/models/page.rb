class Page < ActiveRecord::Base
	has_paper_trail

	has_many :subpages, :class_name => "Page", :foreign_key => "parent_id", :dependent => :destroy, :order => "display_order"

	belongs_to :parent, :class_name => "Page"

	validates_presence_of :title, :body, :display_order

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

	def get_dropdown_title
		dropdown_title = ""

		current = self

		while !current.nil? and !current.parent.nil?
			dropdown_title += "-"

			current = current.parent
		end

		if dropdown_title == ""
			dropdown_title = self.title
		else
			dropdown_title += " " + self.title
		end

		return dropdown_title
	end
end
