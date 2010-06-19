class GroupsController < ApplicationController
	before_filter :logged_in? 
	
	def logged_in?
		redirect_to(login_path) unless current_user
	end
	
  # GET /groups
  # GET /groups.xml
  def index
	#Once sessions are implemented, return all groups where the user has a priveledge
	#A table including all subgroups will be generated.
	Group.rebuild! if nil.|Group.find(:first).rgt
	
	@groups = current_user.get_unique_group_branches
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    Group.rebuild! if nil.|Group.find(:first).rgt
	 @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    Group.rebuild! if nil.|Group.find(:first).rgt
	 @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    Group.rebuild! if nil.|Group.find(:first).rgt
	 @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    Group.rebuild! if nil.|Group.find(:first).rgt
	 @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    Group.rebuild! if nil.|Group.find(:first).rgt
	 @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    Group.rebuild! if nil.|Group.find(:first).rgt
	 @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
