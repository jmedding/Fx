class Group < ActiveRecord::Base
  acts_as_nested_set
  has_many :users
end
