class User < ActiveRecord::Base
	default_scope :order => 'login'
	has_many :groups, 				:through => :priviledges
	has_many :tenders
	has_many :projects	,			:order => "name"
	has_many :priviledges
	has_many :exposures, :through => :tenders
	
	acts_as_authentic
	#attr_accessible :password, :password_confirmation
	
	def get_unique_group_branches
		groups_to_display = []
		self.priviledges.each do|p|
			keep = true
			#only include fresh branches 
			groups_to_display.each do |displayed_group|
				keep = false if p.group.is_or_is_descendant_of?(displayed_group)
				groups_to_display.delete(displayed_group) if displayed_group.is_descendant_of?(p.group)
			end
			groups_to_display << p.group if keep
		end		
		return groups_to_display
	end
	
end
