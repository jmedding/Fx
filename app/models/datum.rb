class Datum < ActiveRecord::Base
	belongs_to :conversion

	def Datum.create_datums(conversion, days)
		datums = conversion.scrape_rates(days)
		datums.each do |d| 
			conversion.data << Datum.create(:conversion_id => conversion.id, :day => d[0],	:rate => d[1])
		end
								
	end


	
end