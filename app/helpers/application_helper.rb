module ApplicationHelper
	def sortable(column, title = nil)
		title ||= column.titleize

		order = column == sort_column && sort_order == "asc" ? "desc" : "asc"

		link_to title, :sort => column, :order => order
	end
end
