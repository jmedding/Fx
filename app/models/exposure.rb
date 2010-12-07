class Exposure < ActiveRecord::Base
	default_scope 						:order => 'currency_out'
	belongs_to :tender
	has_many :rates,					:order => "day", :dependent => :destroy
	belongs_to :conversion
	#belongs_to :user, :through => :tender  #doesn't work,
	
	validates_associated :tender, :conversion, :on => :create
	validates_numericality_of :carried_rate, :current_rate, :amount, :allow_nil => :true
	validates_presence_of :tender, :on => :create
	validate :currencies_are_valid_and_different
	
	def before_save
		self.invert = set_conversion!  if self.invert.blank?
		update_rates!
	end
	
	
		
	def check_carried_blank?
		self.carried_rate.blank? || self.carried_rate <= 0
	end
	
	def set_conversion!
		#try = [conversion, invert]
		try = Conversion.get_conversion(currency_in, currency_out, true)  #true will create a new conversion if it's not found
		p 'set_conversion! failed for exposure ' + id.to_s unless try
		self.conversion = try[0]
		return try[1]	#= -1 if we have to invert
	end
	
	def set_conversion_old!
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
		 #if we make it here, we did not find a valid conversion.
		 #which is strange, because the currencies should have been validated
		 #therefore, lets make a conversion and populate it.
		 c = Conversion.create(:currency_in => currency_in, :currency_out => currency_out)
		 c.populate!
		 self.conversion = c
		 return false		#do not invert the rates
	end
	 
	
	def currencies_are_valid_and_different
		unless (currency_in.blank? && currency_out.blank?)
			errors.add_to_base("Currency_In(#{currency_in}) is not valid!") if Currency.find_by_id(currency_in).blank?
			errors.add_to_base("Currency_Out(#{currency_out}) is not valid!") if Currency.find_by_id(currency_out).blank?
			errors.add_to_base("Currency_In and Currency_Out must be different!") if currency_in == currency_out
		end				
	end
	
  def Exposure.create_with_tender (params, message = nil)
    exp = Exposure.new(params[:exposure])
	  
	  #if the form submits a :tender hash, then the tender is new and needs to be created and assigned
	  unless params[:tender].blank?
		  if params[:tender][:id]
		    tender = Tender.find_by_id(params[:tender][:id])
      else
        tender = Tender.new(params[:tender]) 
		    tender.validity = tender.bid_date + params[:tender][:validity].to_i
      end
	  end
	  unless tender
      p  message = "No tender data received"
      return nil
    end
    unless tender.save
	    p	message = 'Exposure duration information failed to save'
	  	return nil
	  end
	  exp.tender = tender
	  unless exp.save
	    tender.destroy
	    p  message = "Exposure could not be saved"
	    return nil
   end
   return exp
 	end
 	  		
	def Exposure.populate_exposures!
		Exposure.find(:all).each do |e|
			#e.generate_dummy_rates
			#puts e.id
			e.save!
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
		free = tender.user.account.rules.blank?
		f = Array.new
		#The following fields should not be shown to users on the free plan
		unless free
			f << Field.new("Group", tender.group.name)
			f.last.link_object = tender.group
			f << Field.new("Project", tender.project.name)
			f.last.link_object = tender.project
			f << Field.new("Owner", tender.user.name)
			f.last.link_object = tender.user
		end
		
		f << Field.new("Name", tender.description) if free
		f.last.link_object = self if free
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
		#puts tender.description.to_s + ' current_rate for ' + amount_symbol?.to_s + ' is ' + current_rate.to_s
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
  def get_buffer_probabilities(multiple, start = 0)
    i = invert ? -1 : 1
    conversion.get_buffer_probabilities(tender.remaining_validity?, multiple, i, start)
  end
	def update_rates!
		#first calculate remaining validity and multiply be xFactor(=2)
		days_to_analyze = tender.remaining_validity? * 2
		
		#the conversion_id and invert paramater should be set when completing the exposure
		#if there are no rates yet, then seed with the last ten days
		if rates.empty?
			start_date = [Date.today - days_to_analyze, tender.bid_date - 10].min
		else
			start_date = rates.find(:last).day
		end
		end_date = tender.validity + 10
		
		j = 0
		i = invert ? -1 : 1
		data = conversion.data.find(:all, :conditions => ['day > ? and day <= ?', start_date, end_date])
		
		# **** This must be fixed  ************
		#self.carried_rate = (data.first.rate ** i) / 1.05 if self.carried_rate.blank?
		#***********************************
		#update new rates with lates recommended rate
		#probability = 0.5
		#buffer = conversion.find_buffer(tender.remaining_validity?, multiple?, probability, i, 0)/100.0
		#rec = conversion.get_recommended_rate(buffer, i)
		rec = recommended_rate?	
		data.each do |d|
			j+=1		
			#puts j.to_s + " " + fx_symbol? + "=> " + d.day.to_s + " = " + d.rate.to_s
			r = Rate.new(
				:exposure => self, 
				:factor => d.rate  ** i,
				:recommended => rec,
				:carried => carried_rate, 
				:description => (fx_symbol?),
				:day => d.day)
			rates << r
		end
		self.current_rate = rates.last.factor unless rates.empty?
		self.carried_rate = rec if check_carried_blank?

	end
	
	def recommended_rate?
	  i = invert ? -1 : 1
		probability = 0.5
		buffer = conversion.find_buffer(tender.remaining_validity?, multiple?, probability, i, 0)/100.0
		rec = conversion.get_recommended_rate(buffer, i)
  end
	
	def multiple?
    m = 100.0/tender.remaining_validity?
    m = 3 if m < 3
    return m  #need this for testing... Don't know why
	end
	
	def get_probs
	  buffers = get_buffer_probabilities(multiple?)
	  probs = Array.new
	  buffers.each_with_index { |buffer, i| probs << Pointxy.new(knock_down(buffer,3), knock_down(100*(i+1.0)/buffers.size,3))}
	  probs
  end
  
  def knock_down(val, dec)
    val = (((val*10**dec).round).to_f)/10**dec
  end
  
	def title?
	  project = tender.project if tender.project
	  if project
			sub_title = ":" + tender.description
			main_title = tender.project.name
		else
			main_title = tender.description
			sub_title = nil
		end
		group_name = tender.group.name
		direction = "Cash Out"
		direction = "Cash In" if supply
		currency_1 = currency_in_symbol?
		currency_2 = currency_out_symbol?
		currency_1_and_2 = "#{currency_1} => #{currency_2}"
		title = "#{main_title}:#{group_name}#{sub_title}"
		sub = "#{direction}:#{currency_1_and_2}" 
		[title, sub] 
  end
  def prob_chart_title?
    title = "Fx Provision Effectiveness"
		sub = "#{conversion.pair?}, Exposure length = #{tender.remaining_validity?} days"
		[title, sub]
  end
end
