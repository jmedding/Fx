class UsersController < ApplicationController
	protect_from_forgery :except => [:delete, :create]
	
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
	  @group = Group.new()
	  puts "ID = " + params[:group].to_s
	  #if this new user is assigned to an existing group it should be in the params.
	  @group = Group.find_by_id(params[:group][:id]) unless params[:group].blank?
    @user = User.new 
	 @group = Group.new()

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
	def create
		@user = User.new(params[:user])
		#a completely new group should only have a name, with id = nil.	 
		@group = Group.new(params[:group])
		#@group = Group.find_by_id(params[:group][id]) unless params[:group][id].blank?
	 
		#create a priviledge (level = 'user') for this new group. He is not an admin till he pays
		p= Priviledge.new(:user => @user, :group => g, :level => Level.find_by_name('user'))
	 
		respond_to do |format|
			User.transaction do
				@user.save!
				@group.save!
				p.save!
				@group.move_to_child_of(Group.find_by_name("Base")) if @group.parent_id.blank?
				flash[:notice] = 'Registration was successfull.'
				format.html { redirect_to(@user) }
				format.xml  { render :xml => @user, :status => :created, :location => @user }
			end		
		end
	end
	
	rescue ActiveRecord::RecordInvalid => e
		#can keep validating here
		@group.valid?
		p.valid?
		respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
	  end	  
	end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
