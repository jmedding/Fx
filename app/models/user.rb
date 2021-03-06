class User < ActiveRecord::Base
	default_scope :order => 'login'
	has_many :groups, 				:through => :priviledges
	has_many :tenders,				:dependent => :destroy
	has_many :projects	,			:order => "name"
	has_many :priviledges, 		:dependent => :destroy
	has_many :exposures,      :through => :tenders
	belongs_to :account
	
	validates_presence_of :account
	acts_as_authentic
	#attr_accessible :password, :password_confirmation
	
	def can_access_group? group
		groups.each do |g|
			return true if g.is_or_is_ancestor_of?(group)
		end
		return false				
	end
	
	
	def can_access_exposure? (exposure)
		return can_access_group?(exposure.tender.group)
	end
	
	def get_accessible_exposures?
		exposures = []
		groups.each do |node|
			node.get_self_and_children?.each do |g|
				g.tenders.each do |t|
					exposures = exposures | t.exposures
				end				
			end
		end
		return exposures
	end
		
	def get_accessible_tenders?
		tenders = []
		groups.each do |node|
			node.get_self_and_children?.each do |g|
				tenders = tenders | g.tenders
			end
		end
		return tenders
	end
	
def get_accessible_tenders_by_project (project)
		tenders = []
		project.tenders.each do |t|
			tenders << t if can_access_group?(t.group)
		end
		return tenders
	end
	
	def can_access_tender?(tender)
		groups.each do |g|
			return true if g.is_or_is_ancestor_of?(tender.group)
		end 
		return false
	end
	
	def get_unique_group_branches
		#returns the highest common nodes
		groups_to_display = []
		self.priviledges.each do|p|
			keep = true
			#only include fresh branches 
			groups_to_delete = []
			groups_to_display.each do |displayed_group|
				keep = false if p.group.is_or_is_descendant_of?(displayed_group)
				groups_to_delete << displayed_group if displayed_group.is_descendant_of?(p.group)
			end
			groups_to_display = groups_to_display - groups_to_delete
			groups_to_delete = []
			groups_to_display << p.group if keep && !p.group.blank?
		end		
	  return groups_to_display
	end
	
	def can_create_child_group (group)
	  #this is not very efficient. Could pull groups and privides and see if there are any matches.
	  admin_id = Level.find_by_name("admin").id
	  group.self_and_ancestors.each do |g|
	    return true if priviledges.find_by_group_id_and_level_id(g.id, admin_id)
	    group = group.parent
   end
   return false
  end
	
end
