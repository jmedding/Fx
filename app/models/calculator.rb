class Calculator < ActiveRecord::Base
	belongs_to :conversion
	validates_numericality_of :duration, :on => :save	, :only_integer => true, :greater_than => 5, :less_than => 271
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
		0.6
	end
	
	
	def symbols_are_valid
		errors.add_to_base("Currency FROM(#{from}) is not valid!") if Currency.get(from).blank?
		errors.add_to_base("Currency TO(#{to}) is not valid!") if Currency.get(to).blank?
		errors.add_to_base("Currency FROM and Currency TO must be different!") if from == to
	end
	
	def get_provision
		c_in = Currency.get(from)
		c_out =  Currency.get(to)
		return nil unless (c_in && c_out)
		try = Conversion.get_conversion(c_in.id ,	c_out.id)
		return nil unless try[0]
		self.conversion = try[0]
		self.invert = try[1]
		self.duration = 270 if self.duration > 270
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
