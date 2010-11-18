class UserSessionsController < ApplicationController
	skip_before_filter :verify_authenticity_token

  # GET /user_sessions/new
  # GET /user_sessions/new.xml
  def new
    @user_session = UserSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_session }
    end
  end

  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
			  flash[:notice] = @user_session.login + ' successfully logged in.'
			  format.html { redirect_to(exposures_path) }
        #format.html { redirect_to(user_path(current_user)) }
        format.xml  { render :xml => @user, :status => :created, :location => @user_session }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find(params[:id])
    p @user_session.inspect
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to(login_path, :notice => 'Successfully logged out') }
      format.xml  { head :ok }
    end
  end
end
