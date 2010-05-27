class TendersController < ApplicationController
  # GET /tenders
  # GET /tenders.xml
  def index
    @tenders = Tender.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tenders }
    end
  end

  # GET /tenders/1
  # GET /tenders/1.xml
  def show
    @tender = Tender.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tender }
    end
  end

  # GET /tenders/new
  # GET /tenders/new.xml
  def new
    @tender = Tender.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tender }
    end
  end

  # GET /tenders/1/edit
  def edit
    @tender = Tender.find(params[:id])
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
    @tender = Tender.find(params[:id])

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
    @tender = Tender.find(params[:id])
    @tender.destroy

    respond_to do |format|
      format.html { redirect_to(tenders_url) }
      format.xml  { head :ok }
    end
  end
end
