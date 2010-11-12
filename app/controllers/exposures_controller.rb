class ExposuresController < ApplicationController
	before_filter :logged_in? 
	
	def get_exposure_for_user
		e = Exposure.find(params[:id])
		redirect_to exposures_path unless current_user.can_access_exposure?(e)
		#return nil unless e.tender.user == current_user
		return e		
	end
	
	
  # GET /exposures
  # GET /exposures.xml
  def index
    @exposures = current_user.get_accessible_exposures?

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exposures }
    end
  end
  
  
  
  def test
	  render :text => "this works"
  end
  


  # GET /exposures/1
  # GET /exposures/1.xml
  def show
    @exposure = get_exposure_for_user
    @probs = @exposure.get_probs
    @graph = open_flash_chart_object(700,250, "/exposures/graph/#{@exposure.id}")  
    @prob_plot = open_flash_chart_object(700, 250, "/exposures/prob_plot/#{@exposure.id}")  
	 
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exposure }
    end
  end

  # GET /exposures/new
  # GET /exposures/new.xml
  def new
    @exposure = Exposure.new
	 #case: free
		# Create a new tender for each exposure.
		#Include a field in the form for the tender bid date, validity and description
		#The form will check @tender and if validity is nil then it will show the input fields for the tender
		user = User.find(current_user.id) #if user.account.type is changed, current_user won't be udpated automatically
	  if user.account.type_id.blank?	#free plan, no tenders
		  @exposure.tender = Tender.new(:group => current_user.groups.find(:first), :user => current_user)
    else
		  #case: paid
			#p params[:tender]
			tender = (params[:tender].blank? || params[:tender][:id].blank?) ? nil : Tender.find_by_id(params[:tender][:id].to_i)
		  @exposure.tender = tender
  	end
    respond_to do |format|
      if @exposure.tender.blank?
		 	  flash[:notice] = 'An exposure must be created from a tender. Pleae select or create one.'
        format.html { redirect_to(tenders_path) }
        format.xml  { render :xml => @exposure.errors, :status => :unprocessable_entity }
      else
        format.html { render :new }# new.html.erb
        format.xml  { render :xml => @exposure }
      end
    end
  end

  # GET /exposures/1/edit
  def edit
    @exposure = get_exposure_for_user #Exposure.find(params[:id])
	 @tender = @exposure.tender
  end

  # POST /exposures
  # POST /exposures.xml
  def create
    @exposure = Exposure.new(params[:exposure])
	 
	 #if the form submits a :tender hash, then the tender is new and needs created and assigned
	 #by assigning it to the exposure it should get saved when the exposure is saved.
	  unless params[:tender].blank?
		  bid_date = (params["tender"]["bid_date(1i)"].to_s+"-"+params["tender"]["bid_date(2i)"].to_s+"-"+params["tender"]["bid_date(3i)"].to_s).to_date
		  tender = Tender.new(params[:tender]) 
		  tender.validity = tender.bid_date + params[:tender][:validity].to_i
		  tender.user = current_user
		  tender.group = current_user.groups[0]
	  end
	  
    respond_to do |format|
	  	unless tender.save
	  		flash[:notice] = 'Exposure duration information failed to save'
	  		format.html { redirect_to(@exposure) }
	  		format.xml  { render :xml => @exposure, :status => :created, :location => @exposure }
	    end
	  	@exposure.tender = tender
	  	if @exposure.save
	  		#need to update the rates and calculate recommended rate to carry
        flash[:notice] = 'Exposure was successfully created.'        
        format.html { redirect_to(@exposure) }
        format.xml  { render :xml => @exposure, :status => :created, :location => @exposure }
      else
  			#p "Exposure failed to save" + @exposure.inspect
  			tender.destroy
  			format.html { render :action => "new" }
        format.xml  { render :xml => @exposure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exposures/1
  # PUT /exposures/1.xml
  def update
    @exposure = get_exposure_for_user #Exposure.find(params[:id])
	 unless @exposure.tender.update_attributes(params[:tender])
		flash[:notice] = 'Tender data update failed.'
		redirect_to edit_path(@exposure)
	end
	unless params[:exposure][:currency_in] == @exposure.currency_in &&	params[:exposure][:currency_out] == @exposure.currency_out
		#currency has changed
		@exposure.rates.delete_all
		#conversion will be set with 'before_save' callback to set_conversion!
	end
    respond_to do |format|
      if @exposure.update_attributes(params[:exposure])
        flash[:notice] = 'Exposure was successfully updated.'
        format.html { redirect_to(@exposure) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exposure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exposures/1
  # DELETE /exposures/1.xml
  def destroy
    @exposure = get_exposure_for_user #Exposure.find(params[:id])
	 @exposure.tender.destroy
    @exposure.destroy

    respond_to do |format|
      format.html { redirect_to(exposures_url) }
      format.xml  { head :ok }
    end
 end
 
 #/exposure/graph/1
  def prob_plot
		@exposure = get_exposure_for_user #Exposure.find(params[:id])
		v = @exposure.tender.remaining_validity?
		m = multiple?(@exposure.tender.remaining_validity?) #3.0 #multiple
		buffers = @exposure.get_buffer_probabilities(multiple?(@exposure.tender.remaining_validity?))
		n = buffers.size
		main_title = nil
		sub_title = nil
		@exposure = get_exposure_for_user
		currency_1 = @exposure.currency_in_symbol?
		currency_2 = @exposure.currency_out_symbol?
		currency_1_and_2 = "#{currency_1} => #{currency_2}"
		sub_title = ":" + @exposure.tender.description
		main_title = "Fx Provision Effectiveness"
		title = "#{main_title}\n"
		title += "#{currency_1_and_2}, Multiple = #{m}, Exposure length = #{v} days, n = #{n}"
		probs = Array.new	#an array of points for the graph
		#days = Array.new
		#recs = Array.new
		#bid_to_ntp = Array.new
		buffers.each_with_index { |buffer, i| probs << Point.new(buffer, (i+1.0)/buffers.size, 3)}
		#logger.warn("Factors: #{buffers.size}")
		#probs.each {|p| logger.warn p.toString}
		max = 1
		min = 0
		
		g = Graph.new
		g.set_num_decimals(3)
		g.set_bg_color('#FFFFFF')
		g.title(title, '{font-size: 12px;}')
		g.set_x_label_style( 10, '#CC3399', 2,1);
		g.set_y_legend( 'Probability', 12, '#164166' )
		g.set_x_legend( 'Fx Provision (%)', 12, '#164166' )	
		g.set_y_min(min)
		g.set_y_max(max) 
		g.set_y_label_steps(10)
		g.set_x_min(buffers.first.floor)
		g.set_x_max(buffers.last.ceil)
		
		g.scatter(probs, 2, '#736aff', 'Probability', 10)

		render :text => g.render
  end
  
  #/exposure/graph/1
  def graph
		main_title = nil
		sub_title = nil
		@exposure = get_exposure_for_user
		if @exposure.tender.project
			sub_title = ":" + @exposure.tender.description
			main_title = @exposure.tender.project.name
		else
			main_title = @exposure.tender.description
			sub_title = nil
		end
		group_name = @exposure.tender.group.name
		direction = "Cash Out"
		direction = "Cash In" if @exposure.supply
		currency_1 = @exposure.currency_in_symbol?
		currency_2 = @exposure.currency_out_symbol?
		currency_1_and_2 = "#{currency_1} => #{currency_2}"
		title = "#{main_title}:#{group_name}#{sub_title}\n"
		title += "#{direction}:#{currency_1_and_2}"
		factors = Array.new
		carrieds = Array.new
		days = Array.new
		recs = Array.new
		all = Array.new   #throw all values in here to calulcat min and max
		bid_to_ntp = Array.new
		rates = @exposure.rates   #store this data to avoid multiple calls to db
		time_factor = 1000
		point_size = 1
		rates.each do |r|
			#factors << r.factor
			#carrieds << r.carried
			#recs << r.recommended
			#days << r.day
			
			all << r.factor unless r.factor.blank? || r.factor == 0
			all << r.carried unless r.carried .blank? || r.carried == 0
			all << r.recommended unless r.recommended.blank? || r.recommended == 0
			factors << Point.new(r.day.to_time.to_i/time_factor, r.factor, point_size)
			carrieds << Point.new(r.day.to_time.to_i/time_factor, r.carried, point_size)
			recs << Point.new(r.day.to_time.to_i/time_factor, r.recommended, point_size)
			#logger.warn factors.last.toString
		end
    logger.warn	x_min = rates.first.day.to_time.to_i/time_factor
		logger.warn x_max = rates.last.day.to_time.to_i/time_factor
		logger.warn("Factors: #{factors.size}")
		logger.warn("Carried: #{carrieds.size}")
		#logger.warn all.inspect
		max = all.compact.max*1.05	# .min and .max don't like nils
		min = all.compact.min*0.95
		#bid_to_ntp = days.map do |day|
		#	i = min
		#	i = max if ((day >= @exposure.tender.bid_date) && (day < @exposure.tender.validity))		
		#	i
		#end	
	  days.each do |day|
			bd = @exposure.tender.bid_date
			bid_to_ntp << Point.new(day, max, 3) if ((day >= bd) && (day < bd))					
		end
		#factors.each {|f| logger.warn f.toString}
	  g = Graph.new
	  g.set_num_decimals(3)
	  g.set_bg_color('#FFFFFF')
	  g.title(title, '{font-size: 12px;}')
	  #g.set_x_offset(false)

	  g.scatter(factors, point_size, '0x80a033', 'Daily  Rate', 10)
	  g.scatter(carrieds, point_size, '#CC3399', 'Carried rate', 10)
	  g.scatter(recs, point_size, '#EE3399', 'Recomended rate', 10)
	  #g.set_data(factors)
	  #g.line(1, '0x80a033', 'Daily rate', 10)
	  #g.set_data(carrieds)
	  #g.line(1, '#CC3399', 'Carried rate', 10)
	  #g.set_data(recs)
	  #g.line(1, '#EE3399', 'Recomended rate', 10)
	  #g.set_x_labels(days)
	  g.set_x_min(x_min)
	  g.set_x_max(x_max)
	  logger.warn interval = (x_max - x_min)/10
	  g.set_x_label_style( 10, '#CC3399', 2, interval )
	  g.set_y_legend( currency_1 + currency_2, 12, '#164166' )
	  g.set_x_legend( 'Day', 12, '#164166' )	
	  #g.set_data(bid_to_ntp)
	  #g.line(1, '0x80a033', 'Bid Date to NTP', 8)
	  #g.area_hollow(0,0,10,'#031087ff', "Validity", 10)
	  #use several area_hollow lines (safe, caution, under) with corresponding fill colors (green, yellow, red)
	  #to show the current risk level
	  #Would have to graph it as a % margin (with 0 being neutral)
	  g.set_x_axis_steps(interval)
	
	  g.set_y_min(min)
	  g.set_y_max(max) 
	  g.set_y_label_steps(5)
	  
	  render :text => g.render
  end
  
end
