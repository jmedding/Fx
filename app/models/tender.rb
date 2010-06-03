class Tender < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :exposures
  belongs_to :group

  #attr_reader :bid_date, :validity, :user, :description, :project

end
