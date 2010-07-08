class Level < ActiveRecord::Base
	default_scope :order => 'step DESC'
	has_many :priviledges
end
