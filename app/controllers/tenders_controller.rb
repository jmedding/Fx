class TendersController < ApplicationController
	before_filter :logged_in? 
	
	def get_tender_for_user
		#the next line will cause an error if the tender is not found.
		t = Tender.find(params[:id])
		return t if current_user.can_access_tender?(t)
		flash[:notice] = 'This tender is not accessible to ' + current_user
		redirect_to tenders_path
	end
	
  # GET /tenders
  # GET /tenders.xml
  def index
	  
    @tenders = current_user.get_accessible_tenders?

    respond_to do |format|
		if free?
			format.html {redirect_to exposures_path }
		else
			format.html # index.html.erb
			format.xml  { render :xml => @tenders }
		end
		
    end
  end

  # GET /tenders/1
  # GET /tenders/1.xml
  def show
	  
    @tender = get_tender_for_user #Tender.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tender }
    end
  end

  # GET /tenders/new
  # GET /tenders/new.xml
  def new
	  #we should pass the cuurent_user 
    @tender = Tender.new
	 @tender.user = current_user
	 
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tender }
    end
  end

  # GET /tenders/1/edit
  def edit
    @tender = get_tender_for_user #Tender.find(params[:id])
  end

  # POST /tenders
  # POST /tenders.xml
  def create
    @tender = Tender.new(params[:tender])

    respond_to do |format|
      if @tender.save
        flash[:notice] = 'Tender was successfully created.'
        format.html { redirect_to(@tender) }
        format.xml  { render :xml => @tender, :status => :created, :location => @tender }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tender.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tenders/1
  # PUT /tenders/1.xml
  def update
    @tender = get_tender_for_user #Tender.find(params[:id])

    respond_to do |format|
      if @tender.update_attributes(params[:tender])
        flash[:notice] = 'Tender was successfully updated.'
        format.html { redirect_to(@tender) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tender.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tenders/1
  # DELETE /tenders/1.xml
  def destroy
    @tender = get_tender_for_user #Tender.find(params[:id])
    @tender.destroy

    respond_to do |format|
      format.html { redirect_to(tenders_url) }
      format.xml  { head :ok }
    end
  end
end
