class Tender < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :exposures

  #attr_reader :bid_date, :validity, :user, :description, :project

end
