class ExposuresController < ApplicationController
  # GET /exposures
  # GET /exposures.xml
  def index
    @exposures = Exposure.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exposures }
    end
  end
  
  #/exposure/graph/1
  def graph
	  @exposure = Exposure.find(params[:id])
	  project_name = @exposure.tender.project.name
	  group_name = @exposure.tender.user.group.name
	  tender_desc = @exposure.tender.description
	  direction = "Cash Out"
	  direction = "Cash In" if @exposure.supply
	  currency_1 = @exposure.currency_in_symbol?
	  currency_2 = @exposure.currency_out_symbol?
	  currency_1_and_2 = "#{currency_1} => #{currency_2}"
	  title = "#{project_name}:#{group_name}:#{tender_desc}\n"
	  title += "#{direction}:#{currency_1_and_2}"
	  factors = Array.new
	  carrieds = Array.new
	  days = Array.new
	  bid_to_ntp = Array.new
	  @exposure.rates.each do |r|
		  factors << r.factor
		  carrieds << r.carried
		  days << r.day
	  end
	  max = (factors+carrieds).max*1.05
	  min = (factors+carrieds).min*0.95
	  bid_to_ntp = days.map do |day|
		i = min
		i = max if ((day >= @exposure.tender.bid_date) && (day < @exposure.tender.validity))		
		i
	  end	
	  
	  g = Graph.new
	  g.title(title, '{font-size: 12px;}')
	  g.set_data(factors)
	  g.line(1, '0x80a033', 'Daily rate', 10)
	  g.set_data(carrieds)
	  g.line(1, '#CC3399', 'Carried rate', 10)
	  g.set_x_labels(days)
	  g.set_x_label_style( 10, '#CC3399', 2 ,10);
	  g.set_y_legend( currency_1 + currency_2, 12, '#164166' )
	  g.set_data(bid_to_ntp)
	  #g.line(1, '0x80a033', 'Bid Date to NTP', 8)
	  g.area_hollow(0,0,10,'#031087ff', "Bid to NTP", 10)
	  #use several area_hollow lines (safe, caution, under) with corresponding fill colors (green, yellow, red)
	  #to show the current risk level
	  #Would have to graph it as a % margin (with 0 being neutral)

	
	  g.set_y_min(min)
	  g.set_y_max(max) 
	  g.set_y_label_steps(5)
	  
	  
	  #bid << Point.new(@exposure.tender.bid_date, max, 3)
	  #g.scatter(a, 3, '#736aff', 'Bid Date', 10)

	  render :text => g.render
  end
  
  def test
	  render :text => "this works"
  end
  


  # GET /exposures/1
  # GET /exposures/1.xml
  def show
    @exposure = Exposure.find(params[:id])
    @graph = open_flash_chart_object(700,250, "/exposures/graph/#{@exposure.id}")  
    
    

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exposure }
    end
  end

  # GET /exposures/new
  # GET /exposures/new.xml
  def new
    @exposure = Exposure.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exposure }
    end
  end

  # GET /exposures/1/edit
  def edit
    @exposure = Exposure.find(params[:id])
  end

  # POST /exposures
  # POST /exposures.xml
  def create
    @exposure = Exposure.new(params[:exposure])

    respond_to do |format|
      if @exposure.save
        flash[:notice] = 'Exposure was successfully created.'
        format.html { redirect_to(@exposure) }
        format.xml  { render :xml => @exposure, :status => :created, :location => @exposure }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exposure.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exposures/1
  # PUT /exposures/1.xml
  def update
    @exposure = Exposure.find(params[:id])

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
    @exposure = Exposure.find(params[:id])
    @exposure.destroy

    respond_to do |format|
      format.html { redirect_to(exposures_url) }
      format.xml  { head :ok }
    end
  end
end
