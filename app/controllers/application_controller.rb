class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_timezone
   
private

  def set_timezone
    Time.zone = 'America/Chicago'
  end

  def login_required
    if !current_user
      if has_users
        redirect_to :new_session
      else
        create_user
      end
    end
  end
  
  def create_user
    redirect_to :new_user    
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def has_users
    User.find(:all).length > 0
  end

helper_method :current_user

end