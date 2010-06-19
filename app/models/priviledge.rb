class Priviledge < ActiveRecord::Base
	belongs_to :user
	belongs_to :group
	belongs_to :level
end
