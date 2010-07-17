class Priviledge < ActiveRecord::Base
	default_scope :include => [:level], :order => 'levels.step DESC'
	belongs_to :user
	belongs_to :group
	belongs_to :level
	
	def get_fields
		f = Array.new
		f << Field.new("Group", group.name)
		f.last.link_object = self.group
		f << Field.new("Level", level.name)
		return f
	end

end
