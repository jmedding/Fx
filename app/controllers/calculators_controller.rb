class CalculatorsController < ApplicationController
	
	
  # GET /calculators
  # GET /calculators.xml
  def index
    @calculators = Calculator.all
	 s = get_session	#session[:_csrf_token]
	 source = params[:source]
	 puts "session: #{s} at index action"
	 #this is dangerour, becuase if Calculate.create fails validation (currencies don't exist) we get an infiniete loop 
	 @calculator = Calculator.create(:from => 'EUR', :to => 'USD', 
																:duration => 90, :session_id => s, 
																:source_id => source)
    respond_to do |format|
      format.html {redirect_to @calculator}# index.html.erb
      format.xml  { render :xml => @calculators }
    end
  end

  # GET /calculators/1
  # GET /calculators/1.xml
  def show
	@hide_login = "hidden"
	@orig_calculator = Calculator.find(params[:id])
	@provision = @orig_calculator.get_provision	#this must be called first since it sets the conversion and invert params
	@current_rate = @orig_calculator.get_current_rate
	@recommended_rate = @orig_calculator.get_recommended_rate
	@calculator =@orig_calculator.clone 
	#puts 'show action, id = ' + params.to_s
	

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calculator }
    end
  end

  # GET /calculators/new
  # GET /calculators/new.xml
  def new
    @hide_login = "hidden"
	 @calculator = Calculator.new(params[:calculator])	
	 puts 'new action'
		#redirect_to :action => 'create', :calculator => @calculator
    respond_to do |format|      
		format.html # new.html.erb
      format.xml  { render :xml => @calculator }
    end
  end

  # GET /calculators/1/edit
  def edit
	  puts 'edit action'
	  
    @hide_login = "hidden"
    @calculator = Calculator.find(params[:id])
  end

  # POST /calculators
  # POST /calculators.xml
  def create
	@hide_login = "hidden"  
	puts 'create action ' + params.to_s
	@calculator = Calculator.new(params[:calculator])
	@calculator.source_id = 1	#we only get here from the 'caclulate' button
	@calculator.session_id = get_session
    respond_to do |format|
      if @calculator.save
        flash[:notice] = nil #'Calculator was successfully created.'
        format.html { redirect_to @calculator}
        format.xml  { render :xml => @calculator, :status => :created, :location => @calculator }
      else
			
			#flash[:notice] = 'Calculator was not successfully created.'
        format.html { render :action => "new", :calculator => @calculator }
        format.xml  { render :xml => @calculator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /calculators/1
  # PUT /calculators/1.xml
  def update
    @calculator = Calculator.find(params[:id])
	puts 'trying to update now'
    respond_to do |format|
      if @calculator.update_attributes(params[:calculator])
        flash[:notice] = 'Calculator was successfully updated.'
        format.html { redirect_to(@calculator) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @calculator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /calculators/1
  # DELETE /calculators/1.xml
  def destroy
    @calculator = Calculator.find(params[:id])
    @calculator.destroy

    respond_to do |format|
      format.html { redirect_to(calculators_url) }
      format.xml  { head :ok }
    end
 end
 
 def get_session
	 session[:_csrf_token]
 end
 
	#/exposure/graph/1
  def graph
		title = nil
		@c = Calculator.find(params[:id])
		if @c
			title = "#{@c.from}:#{@c.to} #{Date.today} (#{@c.duration} days)"
 		else
			return
		end
		use = @c.get_recommended_rate
		con = @c.conversion
		factors = Array.new
		days = Array.new
		recs = Array.new
		data = con.data.find(:all, :conditions => ["day > ?" , Date.today - @c.duration * @c.multiple])
		logger.warn("Data: #{data.size}")
		data.each do |r|
			factors << r.rate**@c.invert
			recs << use
			days << r.day
		end
		logger.warn("Factors: #{factors.size}")
		logger.warn("Recs: #{recs.size}")
		max = (factors+recs).compact.max*1.05	# .min and .max don't like nils
		min = (factors+recs).compact.min*0.95
		  
	  g = Graph.new
	  g.set_bg_color('#FFFFFF')
	  g.title(title, '{font-size: 12px;}')
	  g.set_data(factors)
	  g.line(1, '0x80a033', 'FX rate', 10)
	  g.set_data(recs)
	  g.line(3, '#CC3399', 'Recommended rate', 10)
	  
	  g.set_x_labels(days)
	  g.set_x_label_style( 10, '#CC3399', 2 ,(data.size/5).floor);
	  g.set_y_legend( @c.from + @c.to, 12, '#CC3399' )
	  
	  g.set_y_min(min)
	  g.set_y_max(max) 
	  g.set_y_label_steps(5)
	  g.set_x_axis_steps((data.size/20).floor)
	  
	  render :text => g.render
  end
end
