class Priviledge < ActiveRecord::Base
	belongs_to :user, :group, :level
end
