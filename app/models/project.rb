class Project < ActiveRecord::Base
	default_scope :order => 'name'
	belongs_to :user
	has_many :tenders
	
	attr_reader :num_exposures, :num_currencies
	attr_writer :num_exposures, :num_currencies
  
	def accessible? user
		return false unless user
		tenders.each do |t|
			return true if user.can_access_group?(t.group)
		end
		return false
	end
	
			
	def get_fields
		set_field_data
		f = Array.new
		f << Field.new("Project", name)
		f.last.link_object = self
		f << Field.new("Description", description)
		f << Field.new("Tenders", tenders.count, true)
		f << Field.new("Exposures", num_exposures, true)
		f << Field.new("Currencies", num_currencies, true)
		return f
	end
	
	def set_field_data
		currencies = []
		exposures = 0
		tenders.each do |t|
			t.exposures.each do |e| 
				currencies = currencies|[(e.currency_in if e.supply), (e.currency_out unless e.supply)]
				exposures += 1
			end
		end
		@num_currencies = currencies.compact.size
		@num_exposures = exposures
	end
	
end
