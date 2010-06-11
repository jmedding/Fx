# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def format_currency(amount, symbol, decimals=0)
		number_to_currency(amount, 
			:delimiter => "'", 
			:unit => symbol, 
			:precision => decimals)
	end
	
end
