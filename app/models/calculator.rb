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
	
	def get_max_duration(con)
	  (con.data.size/multiple).floor
  end
 
	def symbols_are_valid
	  c_from =  Currency.get(from)
	  c_to =  Currency.get(to)
		errors.add_to_base("Currency FROM(#{from}) is not valid!") if c_from.blank?
		errors.add_to_base("Currency TO(#{to}) is not valid!") if c_to.blank?
		errors.add_to_base("Currency FROM and Currency TO must be different!") if from == to
		try = Conversion.get_conversion(c_from.id ,	c_to.id)
		con = try[0]
		if con
		  if con.data.size < multiple * duration
		    max_duration = get_max_duration(con)
		    errors.add_to_base("We are sorry, but our database does not contain sufficient history for (#{from}#{to}) to calculate a provision.")
		    errors.add_to_base("Please limit the duration to a maximum of #{max_duration} days")
		    self.duration = max_duration
      end
		else
		  errors.add_to_base("We are sorry, but this particular currency pair (#{from}#{to}) is not in our database.") 
    end
  
	end
	
	def get_provision
		c_in = Currency.get(from)
		c_out =  Currency.get(to)
		return nil unless (c_in && c_out)
		try = Conversion.get_conversion(c_in.id ,	c_out.id)
		return nil unless try[0]
		self.conversion = try[0]
		self.invert = try[1]
		max_duration = get_max_duration(self.conversion)
		self.duration = max_duration if self.duration > max_duration
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
