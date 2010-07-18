class Currency < ActiveRecord::Base
has_many :accounts

def Currency.get(symbol='EUR')
	c = Currency.find_by_symbol(symbol)
end


end
