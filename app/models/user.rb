class User < ActiveRecord::Base
  belongs_to :group
  has_many :tenders
  has_many :projects
end
