class Group < ActiveRecord::Base
#	default_scope :order => 'self.level'
  acts_as_nested_set
  has_many :users
  has_many :tenders
  has_many :priviledges
  
  
  attr_reader :num_projects, :num_tenders, :num_exposures, :num_currencies
  attr_writer :num_projects, :num_tenders, :num_exposures, :num_currencies
  
  def get_fields
	set_field_data
	f = Array.new
	f << Field.new("Group", name, false, true, self.level)
	f.last.link_object = self
	f << Field.new("Projects", num_projects, true)
	f << Field.new("Tenders", num_tenders, true)
	f << Field.new("Exposures", num_exposures, true)
	f << Field.new("Currencies", num_currencies, true)
	return f
  end

  def get_self_and_children?
	  self_and_descendants
  end
  
  def set_field_data
	projects = []
	currencies = []
	tenders = 0
	exposures = 0
	get_self_and_children?.each do |group|
		#seems to be a problem here.  This query returns the number of tenders, not projects
		group.tenders.each do|t| 
			projects = [t.project]|projects
			t.exposures.each do |e| 
				currencies = currencies|[(e.currency_in if e.supply), (e.currency_out unless e.supply)]
				exposures += 1
			end
			tenders += 1			
		end
		
	end
	@num_currencies = currencies.compact.size
	@num_projects = projects.size
	@num_tenders = tenders
	@num_exposures = exposures
  end
  

end
