class GroupsController < ApplicationController
	before_filter :logged_in? 
	
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
	 #this won't work - it won't find children groups
	 @group = Group.find_by_id(params[:id])
	 @group = nil unless current_user.can_access_group?(@group)
   respond_to do |format|
      if @group
        format.html # show.html.erb
        format.xml  { render :xml => @group }
      else
        flash[:notice] = 'Group invalid or you do not have access to this group.'
        format.html { redirect_to groups_path}
        format.xml { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    Group.rebuild! if nil.|Group.find(:first).rgt
	  @group = Group.new
	  @groups = current_user.get_unique_group_branches.map {|g| g.get_self_and_children?}.flatten

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    Group.rebuild! if nil.|Group.find(:first).rgt
	  @group = Group.find(params[:id])
	  @groups = current_user.get_unique_group_branches
  end

  # POST /groups
  # POST /groups.xml
  def create
    # Must check that user's account allows multiple groups
    Group.rebuild! if nil.|Group.find(:first).rgt
    @group = Group.new(params[:group])
	  
	  if params[:group][:parent_id].blank?
	    Logger.error "Cannot create group via CREATE action withouth parent_id" 
	    flash[:notice] = "Can not create a group this way without a specifying a parent"
    else
	    # Must check that the current_user has admin privileges on parent or a parent of parent.
	    parent = Group.find_by_id(params[:group][:parent_id]) 
      if current_user.can_create_child_group(parent)
        @group.account = parent.account
      else
        flash[:notice] = "You do not have sufficient privileges to create new group for #{parent.name}"
      end  
    end
	    
	 #a new group should be saved, and then an Admin privilige for the creator should be created
	 #note: groups validates presence of 'account'

    respond_to do |format|
      begin
        Priviledge.transaction do	     
	        @group.save!
	        @group.move_to_child_of parent  #awesome nested set action.
	        Priviledge.create!(:user => current_user, :group => @group, :level => Level.find_by_name('admin'))
	        	        
          flash[:notice] = 'Group was successfully created.'
          format.html { redirect_to(@group) }
          format.xml  { render :xml => @group, :status => :created, :location => @group }
        end  
      rescue
        Group.rebuild! #don't know if this is needed, but it can't hurt, except for time.
        @groups = current_user.get_unique_group_branches.map {|g| g.get_self_and_children?}.flatten
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
