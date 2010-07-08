class Exposure < ActiveRecord::Base
	default_scope 						:order => 'currency_out'
	belongs_to :tender
	has_many :rates,					:order => "day"
	belongs_to :conversion
	#belongs_to :user, :through => :tender  #doesn't work,
	
	validates_associated :tender, :conversion, :on => :create
	validates_numericality_of :carried_rate, :current_rate, :amount, :allow_nil => :true
	validates_presence_of :tender, :on => :create
	validate :currencies_are_valid_and_different
	
	def after_initialize
		self.invert = set_conversion!
	end
		
	def set_conversion!
		c = Conversion.find_by_currency_in_and_currency_out(currency_in, currency_out)
		unless c.blank?
			self.conversion = c 
			return false		#do not invert the rates
		end
		c = Conversion.find_by_currency_in_and_currency_out(currency_out, currency_in)
		unless c.blank?
			self.conversion = c
			return true		#rates must be inverted
		end
		 #if we make it here, there is we did not find a valid conversion.
		 #which is strange, because the currencies should have been validated
		 #therefore, let make a conversion and populate it.
		 c = Conversion.create(:currency_in => currency_in, :currency_out => currency_out)
		 c.update!(1000)
		 self.conversion = c
		 return false		#do not invert the rates
	end
	 
	
	def currencies_are_valid_and_different
		unless (currency_in.blank? && currency_out.blank?)
			erros.add_to_base("Currency_In(#{currency_in}) is not valid!") if Currency.find_by_id(currency_in).blank?
			erros.add_to_base("Currency_Out(#{currency_out}) is not valid!") if Currency.find_by_id(currency_out).blank?
			errors.add_to_base("Currency_In and Currency_Out must be different!") if currency_in == currency_out
		end		
	end
	
	def Exposure.populate_exposures!
		Exposure.find(:all).each do |e|
			#e.generate_dummy_rates
			e.update_rates!
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
		f << Field.new("Group", tender.group.name)
		f.last.link_object = tender.group
		f << Field.new("Project", tender.project.name)
		f.last.link_object = tender.project
		#f << Field.new("Tender", description)
		f << Field.new("Owner", tender.user.name)
		f.last.link_object = tender.user
		f << Field.new("Bid Date", tender.bid_date)
		#f << Field.new("Validity", tender.validity)
		f << Field.new("Fx", fx_symbol?)
		f.last.link_object = self
		#f << Field.new("Currency In", currency_in_symbol?)
		#f << Field.new("Currency Out", currency_out_symbol?)
		d= "Cash Out"
		d = "Cash In" if supply
		f << Field.new("Direction", d)
		f << Field.new("Current Rate", format_f(current_rate, 4), true)
		f << Field.new("Carried Rate", format_f(carried_rate, 4), true)
		f << Field.new("Amount", amount, true)
		f.last.currency = amount_symbol?
		f << Field.new("Buffer", format_f((buffer?), 1)+"%", true)
		f << Field.new("Remaining validity", "%d days" % tender.remaining_validity?, true)
		f.last.hover_text = tender.validity
		return f
	end
	
	def format_f (value, decimals)
		return "" if value.blank?
		return  "%.#{decimals}f" % value
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
				:description => (fx_symbol?),
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
	def fx_symbol?
		currency_in_symbol? + ":" + currency_out_symbol?
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
		return nil if (current_rate.blank? || carried_rate.blank?)
		(current_rate - carried_rate)/carried_rate*100
	end
	
	def update_rates!
		#first calculate remaining validity and multiply be xFactor(=2)
		days_to_analyze = tender.remaining_validity? * 2
		
		#the conversion_id and invert paramater should be set when completing the exposure
		#if there are no rates yet, then seed with the last ten days
		if rates.empty?
			if tender.bid_date > Date.today
				days_back = 10 
			else
				days_back = (Date.today - tender.bid_date).to_i + 10
			end			
		else
			days_back = Date.today - rates.find(:last).day
		end
		
		i = invert ? -1 : 1
		offset = conversion.data.count - days_back
		data = conversion.data.find(:all, :offset => offset, :limit => days_back)
		data.each do |d|
			self.carried_rate = (d.rate ** i) / 1.05 if self.carried_rate.blank?
			puts fx_symbol? + "=> " + d.day.to_s + " = " + carried_rate.to_s
			r = Rate.new(
				:exposure => self, 
				:factor => d.rate  ** i, 
				:carried => carried_rate, 
				:description => (fx_symbol?),
				:day => d.day)
			rates << r
			self.current_rate = r.factor
		end
		save!

	end
	
	
end
