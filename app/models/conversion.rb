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
			puts "deleting old data for #{pair?}"
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
			rates = scraper.scrape(uri, {:timeout => 600}) #an array filled with arrays of days [date, o, h, l, c]
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
		probs =  get_buffer_probabilities(validity, multiple, start = 0)
		probs[(probability * probs.size).to_i]
	end
	
	def get_buffer_probabilities(validity, multiple, start = 0)
		nmax = data.size
		if (nmax - start) < validity * (multiple + 1)
			p pair? + "returned nil.  data = #{nmax.to_s} start = #{start} validity = #{validity} multiple = #{multiple}"
			return nil #span = (nmax - start - validity)/validity
		end
		#simulate runs over v*m and find 0 delta pos and prob pos then find the offset
		start_point = nmax - 1 - start
		i = start_point
		deltas = []
		#p pair? + "  data = #{data.count.to_s} start = #{start_point} validity = #{validity} multiple = #{multiple}"
		while i > start_point - validity * multiple do
			delta = (data[i].rate - data[i - validity].rate)/data[i].rate #%
			#p "Run  on #{data[i].day.to_s} has a delta of #{delta}"
			deltas << (data[i].rate - data[i - validity].rate)/data[i].rate * 100 #%
			i = i - 1
		end
		#p deltas.size
		deltas.sort!
		return deltas
	end
	
	def Conversion.evaluate_buffer_params(maxRuns = 100)
		heat_map = []			#heat_map[multiple][probability]
		minV = 15	#minimum validity in days
		maxV = 200#days
		minM = 1.5 #multiple in validities
		maxM = 4.0
		puts
		p "Runs:           " + maxRuns.to_s + "  "
		p "Validity_min:   " + minV.to_s + "  "
		p "Validity_max:   " + maxV.to_s + "  "
		p "Multiple_min:   " + minM.to_s + "  "
		p "Mulitple_max:   " + maxM.to_s + "  "
		p "Currency_pairs: " +Conversion.all.map {|c| "#{c.pair?}, "}.to_s 
		#sum the deltas at a given probability and mulitiple over x number of random runs
		#validity, start date and conversion are random elements
		# 1) Determine conversion, bid_date and validity params
		# 2) Cycle through all possible values of P1 and P2 (Probability and Multiple)
		#3) Normalize all results to make comparable across different volatility periods.
		
		i = 0
		series = []
		probabilities = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]	#get a datapoint at each of these values
		while i < maxRuns
			v = minV + rand(maxV - minV)
			c = Conversion.all[rand(Conversion.count)]
			m = minM
			start = rand(c.data.size - (v * (maxM+1)).to_i )
			results = []
			
			#p c.pair?
			while m < maxM do
				deltas = c.get_buffer_probabilities(v, m, start).collect! {|delta| delta.abs}	
				vars = []
				probabilities.each {|prob| vars<< deltas[(prob * deltas.size).to_i]}
				results << [c.pair?, v, start, p, m, vars]	
			
				m += (maxM - minM)/10.0
			end
			#normalize results	
			n_results = c.normalize!(results,5)
			#create summary by adding the normalized results to that place in the matrix
			n_results.each_with_index do |ar, a|
				heat_map << Array.new if i == 0
				ar[5].each_with_index do |v, b|		# 5 is the location of the array in each ar[]
					#heat_map[multiple][probability]
					heat_map[a] << 0 if i == 0	#have to initialize array on the first pass
					heat_map[a][b]  += v					
				end				
			end					
			i += 1
		end
		c.normalize!(heat_map.collect! {|row| [row]},0)		#wrap heat_map in an array to match the input format of c.normalize! ([[a,b,c,[]],[a,b,c,[]],[a,b,c,[]],...])
		heat_map.collect!{|row| row[0]}	#undwrap heat_map to bring it back into a usable data format ([[],[],[],...])
		puts
		#puts "Number of runs = " + maxRuns.to_s
		ps =  probabilities.map {|p| "   %.2f" % p}
		puts "              " + ps.to_s
		heat_map.each_with_index do |row, m|
			string = "Multiple %.2f:  " % (minM + (maxM - minM)/10.0 *(m))
			row.each { |var| string += "%.2f   " % var }
			
			p string
		end
			
		return 'done'
		#return results		
	end
	
	def normalize!(array_of_arrays, element_to_be_normalized)
		e = element_to_be_normalized
		vals = array_of_arrays.map{|ar| ar[e] }.flatten	
		min = vals.min 		#vals.map {|v| v[e]}.min
		max = vals.max 	#vals.map {|v| v[e]}.max
		scale = 1.0 / (max-min)
		vals.collect! { |val| (val - min)*scale }		
		array_of_arrays.each do |ar| 
			ar[e].collect!{ |val| (val - min)*scale}
		end
			
		return array_of_arrays
	end
	
	def get_recommended_rate(invert=1)
		val = nil
		val = (data.last.rate ** invert) / 1.05 unless data.last.blank?
		val
	end
	
	
end
