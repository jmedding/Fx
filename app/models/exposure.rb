class Exposure < ActiveRecord::Base
belongs_to :tender
has_many :rates

 def generate_dummy_rates
	day = tender.bid_date-(10)
	actual= factor * 1.05
	logger.debug("The first call is to day #{day}")
	while day <= tender.validity do
		actual += actual * 0.02*(0.5 - rand)
 		r = Rate.create(
			:exposure => self, 
			:factor => actual, 
			:carried => factor, 
			:description => (Currency.find(currency_in).symbol + ":" + 
				Currency.find(currency_out).symbol),
			:day => day)
		#r.save
		puts Rate.find(:last).factor
		day = day.next
      end
 end
 
end
