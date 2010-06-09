class PriviledgesController < ApplicationController
  # GET /priviledges
  # GET /priviledges.xml
  def index
    @priviledges = Priviledge.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @priviledges }
    end
  end

  # GET /priviledges/1
  # GET /priviledges/1.xml
  def show
    @priviledge = Priviledge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @priviledge }
    end
  end

  # GET /priviledges/new
  # GET /priviledges/new.xml
  def new
    @priviledge = Priviledge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @priviledge }
    end
  end

  # GET /priviledges/1/edit
  def edit
    @priviledge = Priviledge.find(params[:id])
  end

  # POST /priviledges
  # POST /priviledges.xml
  def create
    @priviledge = Priviledge.new(params[:priviledge])

    respond_to do |format|
      if @priviledge.save
        format.html { redirect_to(@priviledge, :notice => 'Priviledge was successfully created.') }
        format.xml  { render :xml => @priviledge, :status => :created, :location => @priviledge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @priviledge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /priviledges/1
  # PUT /priviledges/1.xml
  def update
    @priviledge = Priviledge.find(params[:id])

    respond_to do |format|
      if @priviledge.update_attributes(params[:priviledge])
        format.html { redirect_to(@priviledge, :notice => 'Priviledge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @priviledge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /priviledges/1
  # DELETE /priviledges/1.xml
  def destroy
    @priviledge = Priviledge.find(params[:id])
    @priviledge.destroy

    respond_to do |format|
      format.html { redirect_to(priviledges_url) }
      format.xml  { head :ok }
    end
  end
end
