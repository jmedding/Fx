# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
	helper_method :current_user
	helper_method :free?
	
	def logged_in?
		redirect_to(login_path) unless current_user
	end
	
	def admin?
	  #Need to think about this functionality. 
	  #if an admin logs on, ok, show admin stuff
	  #if not, then why redirect to groups????
			aps = current_user.priviledges.find(:all, :conditions => ['level_id >= ?', 2])			
			redirect_to(groups_path) if aps.empty?
			aps
	end
	
	
	private
	
	def multiple?(validity)
		m = 101 / validity
		m = 3 if m < 3.0
	end
	
	def current_user_session
		return @current_user_session if defined?(@current_user_session)
		@current_user_session = UserSession.find
	end

	def current_user
		return @current_user if defined?(@current_user)
			@current_user = current_user_session && current_user_session.record
	end
	
	def free?
		puts current_user.account_id
		current_user.account.rules.blank?
	end
	

end
