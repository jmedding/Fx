class Conversion < ActiveRecord::Base
	has_many :data, 		:order => "day"
	has_many :expsosures
	
	def Conversion.generate_conversions!
		Conversion.delete_all
		Datum.delete_all
		bases = Currency.find_all_by_base(true)
		bases.each do |base|
			Currency.all.each do |c|
				Conversion.create(:currency_in => base.id, :currency_out => c.id) unless (base.id == c.id)
			end
		end
		Conversion.update!(1000)
	end
	
	def Conversion.update!(days = -1) 
		Conversion.all.each {|c| c.populate!(days)}
	end
	
	def pair?
		return Currency.find(currency_in).symbol + Currency.find(currency_out).symbol
	end
	
	def populate!(days = -1)
		
		if (self.first.blank? && days > 0)	#first call to new Conversion
			days = days 
		elsif (self.first.blank? && days < 0)	#first call, use default num days
			days = 1000
			data.delete_all #	incase the _first is false and data actually exists
		elsif self.first > Date.today - days #datums exist, but don't go back far enough
			data.delete_all #	must rewrite entire series
		else
			days = Date.today - last 
		end
		# date - integer => rational. Must 	convert rational to integer
		Datum.create_datums(self, days.to_i)
		if data.empty?
			puts pair? + "no data found for #{days} days"
		else
			#puts "is first blank? " + self.first.blank?.to_s
			self.first = data.find(:first).day if self.first.blank?
			#puts "Replace old first? " + ((Date.today - days) < self.first).to_s
			self.first = data.find(:first).day if (Date.today - days) < self.first			
			self.last = data.find(:last).day
			puts pair? + " " + self.first.to_s + " - " + self.last.to_s 
			self.save!
		end
		
	end
	
	def scrape_rates(num_days)
		scraper = Scraper.define do
			array :days
			process "table#tabla2 tr", :days => Scraper.define {
				array :values
				process "td", :values => :text					
				result :values
			}			
			result :days
		end
		num_days =num_days # this website doesn't have data on weekends
		if num_days > 0
			uri = URI.parse("http://www.fxstreet.com/forex-tools/rate-history-tools/?tf=1d&period=#{num_days}&pair=#{pair?}")
			p uri
			rates = scraper.scrape(uri, {:timeout => 300}) #an array filled with arrays of days [date, o, h, l, c]
			vals = []
			unless rates.blank?
				rates.delete_at(0)	#first row has header text
				rates.each {|r| vals << [r[0], (Float(r[2])+Float(r[4]))/2] if r.length >=5}
			end			
			return vals
		end
		p "Not scraped. Days = #{days}"
		return []	#days was less than one, so return an empty set.
	end
	
end
