class Field
	attr_reader :header, :text
	attr_writer :header, :text
	
	def initialize (header, text)
		@header = header
		@text = text
	end
end

		