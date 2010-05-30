class Exposure < ActiveRecord::Base
belongs_to :tender
has_many :rates

 def generate_dummy_rates
	 Rate.delete_all(["exposure_id = ?", id])
	day = tender.bid_date-(10)
	actual= factor * 1.05
	logger.debug("The first call is to day #{day}")
	while day <= tender.validity do
		actual += actual * 0.02*(0.5 - rand)
 		rates << Rate.new(
			:exposure => self, 
			:factor => actual, 
			:carried => factor, 
			:description => (Currency.find(currency_in).symbol + ":" + 
				Currency.find(currency_out).symbol),
			:day => day)
		#r.save
		#puts Rate.find(:last).factor
		#puts rates.last.factor
		day = day.next
	end
	#save
	return 	Rate.find_all_by_exposure_id(id).length
 end
 
end
