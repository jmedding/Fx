class Conversion < ActiveRecord::Base
	has_many :data, 		:order => "day", 	:dependent => :destroy
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
		Conversion.update!(1500)
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
			reset_data!
			days = 1500
		elsif self.first > Date.today - days #datums exist, but don't go back far enough
			reset_data!
		else
			days = Date.today - last 
		end
		# date - integer => rational. Must 	convert rational to integer
		Datum.create_datums(self, days.to_i)
		if self.data.all.size < 1 #empty?
			puts pair? + " no data found for #{days} days"
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
	
	def reset_data!
			data.delete_all #	must rewrite entire series
			puts "deleting old data"
			self.first = nil
			self.last = nil
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
		p "Not scraped. Days = #{num_days}"
		return []	#days was less than one, so return an empty set.
	end
	
	def find_buffer(validity, multiple, probability, start = 0)
		nmax = data.size
		if (nmax - start) < validity * (multiple + 1)
			p pair? + "returned nil.  data = #{nmax.to_s} start = #{start} validity = #{validity} multiple = #{multiple}"
			return nil #span = (nmax - start - validity)/validity
		end
		#simulate runs over v*m and find 0 delta pos and prob pos then find the offset
		start_point = nmax - 1 - start
		i = start_point
		deltas = []
		p pair? + "  data = #{data.count.to_s} start = #{start_point} validity = #{validity} multiple = #{multiple}"
		while i > start_point - validity * multiple do
			delta = (data[i].rate - data[i - validity].rate)/data[i].rate #%
			#p "Run  on #{data[i].day.to_s} has a delta of #{delta}"
			deltas << (data[i].rate - data[i - validity].rate)/data[i].rate * 100 #%
			i = i - 1
		end
		#p deltas.size
		deltas.sort!
		buffer = deltas[(probability * deltas.size).to_i]
		return buffer
	end
	
	def Conversion.evaluate_buffer_params
		minV = 15	#minimum validity in days
		maxV = 250#days
		minM = 0.5 #multiple in validities
		maxM = 3.0
		maxRuns = 10	#must be > 0
		
		#sum the deltas at a given probability and mulitiple over x number of random runs
		#validity, start date and conversion are random elements
		p = 0.10
		results = []
		while p < 1.0 do
			series = []
			m = minM
			while m < maxM do
				varSum = 0
				i = 0
				while i < maxRuns
					v = minV + rand(maxV - minV)
					c = Conversion.all[rand(Conversion.count)]
					start = rand(c.data.size - v * (m+1) )
					var = nil
					while var == nil
						start -= 1
						var = c.find_buffer(v, m, p, start) 		
					end
					varSum += var**2
					i += 1
				end				
				series << varSum/maxRuns
				p "result for probabilit = #{p*100}% and multiple = #{m} = #{var**2}"
				m += (maxM - minM)/10
			end
			results << series
			p += 0.1
		end
		return results		
	end
	
	def get_recommended_rate(invert=1)
		val = nil
		val = (data.last.rate ** invert) / 1.05 unless data.last.blank?
		val
	end
	
	
end
