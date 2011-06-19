module Messages
	def format_error_messages(errors)
        errors.map {|attribute, message| "Error: #{attribute.titleize} #{message}.<br />"}
	end

	def error_message_could_not_find(object_name)
		return "Error: Unable to find the specified " + object_name + "!"
	end

	def error_message_could_not_create(object_name)
		return "Error: Unable to create the " + object_name + "!"
	end

	def error_message_could_not_save(object_name)
		return "Error: Unable to save " + object_name + " to database!"
	end

	def error_message_could_not_update(object_name)
		return "Error: Unable to update " + object_name + "!"
	end

	def error_message_could_not_destory(object_name)
		return "Error: Unable to destroy " + object_name + "!"
	end

	def notice_message_created(object_name)
		return object_name.capitalize + " has been created!"
	end

	def notice_message_updated(object_name)
		return object_name.capitalize + " has been updated!"
	end

	def notice_message_destroyed(object_name)
		return object_name.capitalize + " has been deleted!"
	end
end
