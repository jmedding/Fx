class UsersController < ApplicationController
	before_filter :logged_in?, :except => [:new, :create]
	before_filter :admin?, :except => [:new, :edit, :update, :create, :destroy]
	protect_from_forgery :except => [:destroy, :create]
	
	
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
		#	get business rules for each account type
	  #if this new user is assigned to an existing group it should be in the params.
		@group =  params[:group].blank? ? Group.new() : Group.find_by_id(params[:group][:id])
    @group.name ||= "MyGroup"
		@user = User.new()

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
#    p @user.inspect
#    p current_user.inspect
    redirect_to current_user unless @user == current_user
  end

  # POST /users
  # POST /users.xml
  #This action is tied to the regestration of a new user and implies a new account
	def create
		@user = User.new(params[:user])
		@user.login ||= @user.email   #only email is required to create an account
		@user.name ||= @user.login    #these two fields can be edited later
		params[:group][:name] ||= @user.login #same for the group param
		
		#a completely new group should only have a name, with id = nil.	 
		@user.account = @group.account if @group = Group.find_by_id(params[:group][:group_id])
    message = nil
      
		respond_to do |format|
		  begin
		    User.transaction do
			    @group ||= Group.new(params[:group])
  				@user.account ||= Account.create!()  #only create new account if it is empty
  				@user.save!
  				@user.account.creator_id = @user.id
   				UserSession.create(:login => params[:user][:login], :password => params[:user][:password])
  				@group.account = @user.account
  				@user.account.save!				
  				@group.save!
			    Priviledge.create!(:user => @user, :group => @group, :level => Level.find_by_name('user'))
  				base = base_group     #base_group defined in application_controller
  				Group.rebuild! unless base.lft || base.rgt  #needed for testing
  				@group.move_to_child_of(base) if @group.parent_id.blank?
  				
  				flash[:notice] = 'Registration was successfull.'
  				
  				#Test for session[:calculator]. If it exists, then redirect to exposures.create with appropriate input params
  				if session[:calculator]
  				  params = {  :tender => {  :validity => session[:calculator][:duration].to_i, 
  				                            "bid_date(1i)" => Date.today.strftime("%Y"),
  				                            "bid_date(2i)" => Date.today.strftime("%m"),
  				                            "bid_date(3i)" => Date.today.strftime("%d"),
  				                            :description => @user.login + "_01",
  				                            :group => @group,
                				              :user => @user},
  				              :exposure => {:currency_in => Currency.get(session[:calculator][:from]).id, 
  				                            :currency_out => Currency.get(session[:calculator][:to]).id,
  				                            :amount => 1000000 }  				              
  				            }
  				  @exposure = Exposure.create_with_tender(params, message)
  				  if message.blank? && @exposure
  				     format.html {redirect_to @exposure}
				    else
				      p "uh oh " + message.to_s+"<=end of message"
				      flash[:notice] = message
  			      format.html { render :controller => "exposures", :action => new, :params => params }
			      end
				  else
  				  format.html { redirect_to(current_user) }
  				  format.xml  { render :xml => @user, :status => :created, :location => @user }
				  end
  			end		
	    rescue ActiveRecord::RecordInvalid
	      p "didn't make it on user save"
	      p message
	      format.html { render :action => "new"}  #render is better than redirect, because it preserves all of the @user data
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
		end
	end
	
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user == current_user && @user.update_attributes(params[:user])
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
    #p (@user == current_user).to_s
    @user.destroy if @user == current_user

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
 end

end
