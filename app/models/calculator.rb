class Calculator < ActiveRecord::Base
	belongs_to :conversion
	validates_numericality_of :duration, :on => :save	, :only_integer => true, :greater_than => 5, :less_than => 2710
	validates_presence_of :from
	validates_presence_of :to
	validate :symbols_are_valid
	attr_reader :multiple, :prob
	
	def before_save
		get_provision
	end
	
	def multiple 
		3.0
	end
	
	def prob
		0.5
	end
	
	def get_max_duration
	  (conversion.data.size/multiple).floor
  end
 
	def symbols_are_valid
	  c_from =  Currency.find_by_symbol(from)
	  c_to =    Currency.find_by_symbol(to)
		errors.add_to_base("Currency FROM(#{from}) is not valid!") if c_from.blank?
		errors.add_to_base("Currency TO(#{to}) is not valid!") if c_to.blank?
		errors.add_to_base("Currency FROM and Currency TO must be different!") if from == to
		return if c_from.blank? || c_to.blank? || from == to
		try = Conversion.get_conversion(c_from.id ,	c_to.id)
		con = try[0]
		if con
		  self.conversion = con
      self.invert = try[1] ? -1 : 1
      if con.data.size < multiple * duration
		    errors.add_to_base("We are sorry, but our database does not contain sufficient history for (#{from}#{to}) to calculate a provision.")
		    errors.add_to_base("Please limit the duration to a maximum of #{get_max_duration} days")
		    self.duration = get_max_duration
      end
		else
		  errors.add_to_base("We are sorry, but this particular currency pair (#{from}#{to}) is not in our database.") 
    end
    
  
	end
	
	def get_provision
		@multiple = multiple
		@prob = prob
		self.provision = self.conversion.find_buffer(duration, multiple, prob, self.invert, nil)
		
	end
	def get_current_rate
		self.conversion.get_current_rate(self.invert)
	end
	
	def get_recommended_rate
		get_current_rate*(1.0 - provision/100)
	end
	
	
	
end
