require "sanitize"
require "rexml/parsers/pullparser"

class String
	def possessive
		self + case self[-1, 1]
			when 's' then "'"
			else "'s"
		end
	end
end

module TextModule
	def make_possessive(word)
		if word[-1, 1] == 's'
			return word + "'"
		else
			return word + "'s"
		end
	end

	def remove_html(text)
		if text != nil and text != ""
			text = Sanitize.clean(text)

			text.gsub!("\n", "")

			text.gsub!("&#13;", "\n")

			text.gsub!(/$/, '<br />')
		end

		text.gsub!(/(<br \/>\s*)*$/, '')

		text.gsub!(/^(\s*<br \/>)*/, '')

		text.strip!

		return text
	end

	def unix_timestamp
		timestamp = Time.now.to_i.to_s + Time.now.usec.to_s

		pad = 16 - timestamp.length

		pad.times do
			timestamp += "0"
		end

		return timestamp
	end

	def generate_random_file_number(length = 16)
		timestamp = Time.now.to_i.to_s + Time.now.usec.to_s

		pad = 16 - timestamp.length

		pad.times do
			timestamp += "0"
		end

		return timestamp

		#use timestamp instead of random number
		#number = ""

		#chars = ("0".."9").to_a

		#length.times do
			#number << chars[rand(chars.length - 1)]
		#end

		#return number
	end

	def generate_cookie_code
		cookie_code = ""

		chars = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a

		128.times do
			cookie_code << chars[rand(chars.length - 1)]
		end

		return cookie_code
	end

	def truncate(text, length = 1024, ending = "...")
		def attrs_to_s(attrs)
			return '' if attrs.empty?

			attrs.to_a.map { |attr| %{#{attr[0]}="#{attr[1]}"} }.join(' ')
		end

		if length <= 0
			return text
		end

		begin
			parser = REXML:: Parsers::PullParser.new(text)

			tags = []

			new_length = length

			results = ''

			while parser.has_next? && new_length > 0
				parser_event = parser.pull

				case parser_event.event_type
					when :start_element
						tags.push parser_event[0]

						results << "<#{tags.last} #{attrs_to_s(parser_event[1])}>"
					when :end_element
						results << "</#{tags.pop}>"
					when :text
						results << parser_event[0].slice(0, new_length)

						new_length -= parser_event[0].length
					else
						results << "<!-- #{parser_event.inspect} -->"
				end
			end

			tags.reverse.each do |tag|
				results << "</#{tag}>"
			end

			return results.to_s + (text.length > length ? ending : '')
		rescue REXML::ParseException
			return text
		end
	end
end
