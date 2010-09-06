class Currency < ActiveRecord::Base
has_many :accounts

	def Currency.get(symbol='EUR')
		c = Currency.find_by_symbol(symbol)
	end

	def get_valid_conversions
		if base
			#return all other currencies (not including this one)
			cs = Currency.all.delete(self)
		else
			#return all base currencies
			Currency.find_all_by_base(true)
		end
		
	end

end
