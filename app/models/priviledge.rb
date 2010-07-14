class Priviledge < ActiveRecord::Base
	default_scope :include => [:level], :order => 'levels.step DESC'
	belongs_to :user
	belongs_to :group
	belongs_to :level
end
