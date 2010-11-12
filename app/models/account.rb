class Account < ActiveRecord::Base
	has_one :group,		:dependent => :destroy  #it may be easier to have multiple groups, due to the nested set relationshipsai
	belongs_to :currency
	#belongs_to :type #Must uncomment this when we add real types!!!!!!!
	belongs_to :rules
	has_many :users, 	:dependent => :destroy
	#has_many :invoices
	
	def get_fields
		f = Array.new
		f << Field.new("Pament", payment, true)
		f << Field.new("Currency", curreny.symbol)
		#f.last.link_object = self
		f << Field.new("Period", period, true)
		f << Field.new("CC Number", cc_num)
		f << Field.new("CC_Exp", cc_exp)
		f << Field.new("CC Code", cc_code)
		f << Field.new("CC Name", cc_name)
		f << Field.new("PayPal", paypal)
		return f
	end
	
	def name
		return group.name
	end
	

end
