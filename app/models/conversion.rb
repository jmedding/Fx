class Conversion < ActiveRecord::Base
	has_many :data, 		:order => "day", 	:dependent => :destroy
	has_many :expsosures, 								:dependent => :destroy
	has_many :calculators,								:dependent => :destroy
	
	def Conversion.generate_conversions!
		Conversion.delete_all
		Datum.delete_all
		bases = Currency.find_all_by_base(true)
		bases.each do |base|
			Currency.all.each do |c|
				unless (base.id == c.id || Conversion.find_by_currency_in_and_currency_out(c.id, base.id))
					con = Conversion.create(:currency_in => base.id, :currency_out => c.id)					
				end				
			end
		end
		Conversion.import_all_from_yaml
		Conversion.update!
		Conversion.export_all_to_yaml
	end
	
	def Conversion.import_all_from_yaml
		Conversion.find(:all).each { |c| c.yaml_import(1500, false)}
	end
	def Conversion.export_all_to_yaml
		Conversion.find(:all).each { |c| c.yaml_export}
	end
	
	def yaml_export
		text = data.to_yaml
		text.gsub!("/\n/", "\r\n")
		File.create("./db/seeds//#{RAILS_ENV}/", "d") unless File.open("./db/seeds//#{RAILS_ENV}")
		File.open("./db/seeds//#{RAILS_ENV}/#{pair?}.yaml", 'w') {|f| f.write(text) }
	end
		
	def yaml_import (days = 1500, export = false)
	  #should only be called from 'Conversion.generate_convesions' other wise, data will not be updated properly
		reset_data!
		file = "./db/seeds/#{RAILS_ENV}/"+pair?+".yaml"
		p 'try to load from ' + file 
		# check to see if 'file' exists. If so, then load it
		if File.exists? file
			puts 'loading file: ' + file
			data = YAML.load_file(file)
			data.each do |d|
				#d.id = nil
				d.instance_variable_set "@new_record", true
				self.data << d
			end			
			self.save!
		end		
		set_data #set this conversions first and last day attributes
		#finally, run update to make the dataset current
		#populate!(days) #can't do this as the id's get carried over from the file and there may already be one for later imports. Instead, run Update all after all imports are done.
		#export the data so that next time is current
		yaml_export if export	#seems to cause problems in the YAML export. Test before using...
	end
	
	
	def Conversion.update!(days = -1) 
		Conversion.all.each {|c| c.populate!(days)}
	end
	
	def Conversion.get_conversion(currency_in, currency_out, create_new = false)
		c = Conversion.find_by_currency_in_and_currency_out(currency_in, currency_out)
		unless c.blank?
			return [c, false]		#do not invert the rates
		end
		c = Conversion.find_by_currency_in_and_currency_out(currency_out, currency_in)
		unless c.blank?
			return [c, true]		#rates must be inverted
		end
		 #if we make it here, we did not find a valid conversion.
		 #which is strange, because the currencies should have been validated
		 #therefore, lets make a conversion and populate it.
		if create_new
			c = Conversion.create(:currency_in => currency_in, :currency_out => currency_out)
			c.populate!
			return [c, invert]		#do not invert the rates
		else
			return [nil,nil]		#not allowed to create a new conversion
		end
		
	 end
	 
	def pair?
		return Currency.find(currency_in).symbol + Currency.find(currency_out).symbol
	end
	
	def populate!(days = -1)		
		if (self.first.blank? && days > 0)	#first call to new Conversion
			days = days 
		elsif (self.first.blank? && days < 0)	#first call, use default num days
			#puts 'first:' + self.first.to_s
			#puts 'days: ' + days.to_s
			reset_data!
			days = 1500
		elsif self.first > Date.today - days + 2 #datums exist, but don't go back far enough
			reset_data!
		else
			days = Date.today - last 
		end
		# date - integer => rational. Must 	convert rational to integer
		Datum.create_datums(self, days.to_i)
    clean_data
		set_data		
	end
	
	def set_data
		if self.data.all.size < 1 #empty?
			puts pair? + " no data found"
		else
			#puts "is first blank? " + self.first.blank?.to_s
			self.first = data.find(:first).day 
			self.last = data.find(:last).day
			#puts pair? + " " + self.first.to_s + " - " + self.last.to_s 
			self.save!
		end
	end
	
	
	def reset_data!
			data.delete_all #	must rewrite entire series
			puts "deleting old data for #{pair?}"
			self.first = nil
			self.last = nil
	end

  def clean_data
    last_day = nil
    data.each do |d|
      data.delete(d) if (d.day == last_day && last_day)
      last_day = d.day if d
    end
  end		

	def scrape_rates(num_days)
		scraper = Scraper.define do
			array :days
			#process "table#tabla2 tr", :days => Scraper.define {
			process "table:nth-of-type(2) tr", :days => Scraper.define {
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
			#add :parser => :html_parser to scrape call below to avoid using tidy, which doesn't want to work on AMD64 server...
			rates = scraper.scrape(uri, {:timeout => 600, :parser => :html_parser}) #an array filled with arrays of days [date, o, h, l, c]
			p rates.nil? ? "No data found" : "data downloaded for #{rates.count.to_s} days"
			vals = []
			unless rates.blank?
				rates.each {|r| vals << [r[0], (Float(r[2])+Float(r[4]))/2] if r.length >=5}
			end			
			return vals
		end
		p "Not scraped. Days = #{num_days}"
		return []	#days was less than one, so return an empty set.
	end
	
	def find_buffer(validity, multiple, probability, invert, start = 0)
		probs =  get_buffer_probabilities(validity, multiple, invert, start = 0)
		probs[(probability * probs.size).to_i]
	end
	
	def get_buffer_probabilities(validity, multiple, invert, start = 0)
		nmax = data.size
		start_point = nmax - 1 - start
		if (start_point+1) < (validity * multiple)
			p pair? + " returned nil.  data = #{nmax.to_s}, start_point= #{start_point}, validity = #{validity}, multiple = #{multiple}"
			return nil #span = (nmax - start - validity)/validity
		end
		#simulate runs over v*m and find 0 delta pos and prob pos then find the offset
		
		i = start_point
		deltas = []
		#p pair? + "  data = #{data.count.to_s} start = #{start_point} validity = #{validity} multiple = #{multiple}"
		while i > start_point - validity * multiple do
			s = data[i - validity].rate ** invert
			e = data[i].rate ** invert
			#delta = (data[i].rate - data[i - validity].rate)/data[i].rate #%
			#p "Run  on #{data[i].day.to_s} has a delta of #{delta}"
			#deltas << - (e - s)/e * 100 #% - provision will be based on the trend
			#p (e - s).abs/e * 100
			deltas << (e - s).abs/s * 100 #% - provision based on volatility
			
			i = i - 1
		end
		#p deltas.size
		deltas.sort!
		
		return deltas
	end
	
	def Conversion.evaluate_buffer_params(maxRuns = 100)
		heat_map = []			#heat_map[multiple][probability]
		minV = 15	#minimum validity in days
		maxV = (270.0*5/7).floor #days
		minM = 2.0#multiple in validities
		maxM = 5.0
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
			nMax = c.data.size
			v = (nMax/(maxM + 1)).to_i - 10 if v * (maxM+1) > nMax - 10 #10 is a fudge factor...
			start = v + 2 + rand(nMax - ((1+maxM)*v).to_i-3)
			#start = v * maxM + 1 + rand(nMax - (1 + v * (maxM+1)).to_i )
			#find actual variation for this exposure			
			results = []
			invert = [-1,1]
			inv = invert[rand(2)]
			s = c.data[start].rate**inv
			e = c.data[start + v].rate**inv
			var_actual = ((e - s)/s * 100).abs
			
			#p c.pair? + " #{inv}"
			#p var_actual
			#p v
			while m < maxM do
				deltas = c.get_buffer_probabilities(v, m, inv, start) #.collect! {|delta| delta.abs}	#don't need to take abs as it is done before now
				vars = []
				#p m
				#probabilities.each {|prob| puts "#{deltas[(prob * deltas.size).to_i] } #{deltas[(prob * deltas.size).to_i]-var_actual }"}
				
				probabilities.each {|prob| vars<< (deltas[(prob * deltas.size).to_i] - var_actual).abs}
				results << [c.pair?, v, start, p, m, vars]	
			
				m += (maxM - minM)/10.0
			end
			#p results[9][0].to_s + " " + "#{results[9][1]}       %.3f" % results[9][5][4]
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
		heat_map.collect!{|row| row[0]}	#unwrap heat_map to bring it back into a usable data format ([[],[],[],...])
		puts
		#puts "Number of runs = " + maxRuns.to_s
		ps =  probabilities.map {|p| "   %.2f" % p}
		puts "             " + ps.to_s
		heat_map.each_with_index do |row, m|
			string = "Multiple %.2f  " % (minM + (maxM - minM)/10.0 *(m))
			row.each { |var| string += "%.2f   " % var }
			p string
		end
			
		return 'done'
		#return results		
	end
	
	def p_row (m, vars)
		string = "Multiple %.2f  " % (minM + (maxM - minM)/10.0 *(m))
		vars.each { |var| string += "%.2f   " % var }
		p string
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
	
	def get_recommended_rate(buffer, invert=1)
		val = nil
		val = get_current_rate(invert) * (1.0 - buffer) unless data.last.blank?
		val
	end
	
	def get_current_rate(invert = 1)
		(data.last.rate ** invert)
	end
	


	
end
