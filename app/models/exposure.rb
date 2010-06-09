class Exposure < ActiveRecord::Base
	belongs_to :tender
	has_many :rates

	def Exposure.populate_exposures!
		Exposure.find(:all).each do |e|
			e.generate_dummy_rates
		end
	end
	
	def Exposure.get_header_fields
		e = Exposure.create( 
			:currency_in => 1, :currency_out => 2,
			:supply => true, :current_rate => 1, 
			:carried_rate => 1, :amount => 20)
		f = e.get_fields
		e.destroy
		return f		
	end
	
	def get_fields
		f = Array.new
		f << Field.new("Currency In", currency_in_symbol?)
		f << Field.new("Currency Out", currency_out_symbol?)
		d= "Cash Out"
		d = "Cash In" if supply
		f << Field.new("Direction", d)
		f << Field.new("Current Rate", "%.4f" % current_rate, true)
		f << Field.new("Carried Rate", "%.4f" % carried_rate, true)
		f << Field.new("Amount", amount_symbol? + " %.0f" % amount, true)
		f << Field.new("Buffer", "%.1f %" % (100*buffer?), true)
		f << Field.new("Remaining validity", "%d days" % remaining_validity?, true)
		return f
	end
	
	
	def generate_dummy_rates
		rates.delete_all
		day = tender.bid_date-(10)
		actual= carried_rate * 1.05
		#logger.debug("The first call is to day #{day}")
		while day <= Date.today do
			actual += actual * 0.02*(0.5 - rand)
			r = Rate.new(
				:exposure => self, 
				:factor => actual, 
				:carried => carried_rate, 
				:description => (currency_in_symbol? + ":" + currency_out_symbol?),
				:day => day)
			rates << r
			self.current_rate = r.factor
			#r.save
			#puts  current_rate
			#puts rates.last.factor
			day = day.next
		end
		save
		puts tender.description.to_s + ' current_rate for ' + amount_symbol?.to_s + ' is ' + current_rate.to_s
		return 	Rate.find_all_by_exposure_id(id).length
	end
	
	def amount_symbol?
		return currency_out_symbol? unless supply
		return currency_in_symbol? if supply
	end
	def currency_in_symbol?
		Currency.find(currency_in).symbol
	end
	def currency_out_symbol?
		Currency.find(currency_out).symbol
	end
	def group?
		tender.group.name
	end
	def project?
		tender.project.name
	end
	def direction?
		t = "Cash In" if supply
		t = "Cash Out" unless supply
		t
	end
	def buffer?
		(current_rate - carried_rate)/carried_rate
	end
	def remaining_validity?
		v = 0
		if tender
			if Date.today > tender.bid_date
				v = (tender.validity - Date.today).to_i
			else
				v = (tender.validity - tender.bid_date).to_i
			end
		end		
		return v if v > 0
		return 0	#can not have a negative validity period...
	end
	
	
end
