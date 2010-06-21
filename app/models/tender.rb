class Tender < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :exposures
	belongs_to :group
	

	#attr_reader :bid_date, :validity, :user, :description, :project
	
	def get_fields
		f = Array.new
		f << Field.new("Group", group.name)
		f.last.link_object = group
		f << Field.new("Project", project.name)
		f.last.link_object = project
		f << Field.new("Tender", description)
		f.last.link_object = self
		f << Field.new("Owner", user.name)
		f.last.link_object = user
		f << Field.new("Bid Date", bid_date)
		f << Field.new("Validity", validity)
		f << Field.new("Days", remaining_validity?, true)
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
	
	def remaining_validity?
		v = 0
		if Date.today > bid_date
			v = (validity - Date.today).to_i
		else
			v = (validity - bid_date).to_i
		end
		return v if v > 0
		return 0	#can not have a negative validity period...
	end
end
