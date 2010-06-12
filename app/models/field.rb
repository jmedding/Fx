class Field
	attr_reader :header, :text, :is_number, :is_nested_set, :level, :link_object, :currency, :hover_text
	attr_writer :header, :text, :is_number, :is_nested_set, :level, :link_object, :currency, :hover_text
	
	def initialize (header, text, is_number=false, is_nested_set=false, level=0)
		@header = header
		@text = text
		@is_number = is_number
		@is_nested_set = is_nested_set
		@level = level
		@link_object = nil
		@currency = nil
		@hover_text = nil
	end
	
end


		