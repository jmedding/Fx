class Tender < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :exposures
  belongs_to :group

  #attr_reader :bid_date, :validity, :user, :description, :project
  
  def get_fields
		f = Array.new
		f << Field.new("Group", group.name)
		f << Field.new("Project", project.name)
		f << Field.new("Tender", description)
		f << Field.new("Owner", user.name)
		f << Field.new("Bid Date", bid_date)
		f << Field.new("Validity", validity)
		return f
	end
	
	def Tender.get_header_fields
		f = Array.new
		#f << Project.get_header_fields
		e = Tender.create( 
			:project => Project.find(:first),
			:group => Group.find(:first),
			:description => "dummy tender",
			:owner => User.find(:first),
			:bid_date => Date.today, 
			:validity => Date.today)
		f << e.get_fields
		e.destroy
		return f
	end

end
