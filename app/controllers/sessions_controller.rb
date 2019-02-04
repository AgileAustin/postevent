require 'securerandom'
require 'logger'

class SessionsController < ApplicationController
  def new
    remove_nonce
    render "new"
  end
  def create
    remove_nonce
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      association_nonce = params[:nonce]
      if not association_nonce.nil? and not association_nonce.empty?
          association = Associations.find_by_nonce(association_nonce)
          time_now = Time.now
          if not association or time_now >= association.nonce_expiration_time
            render "slack_expired_nonce" and return
          else
            association.update_attributes(:nonce_expiration_time => Time.now)
            user.update_attributes(:slack_user_id => association.user_id)
            flash.now.alert = "Successfully connected slack to PostEvent."
          end
      end
      session[:user_id] = user.id
      redirect_to root_url
    else
      session[:nonce] = params[:nonce]
      flash.now.alert = "Invalid email or password"
      render "new"
      remove_nonce
    end
  end

  def destroy
    logout_user
    redirect_to root_url, :notice => "Logged out!"
  end

  def connect_slack
    association_nonce = params[:nonce]
    association = Associations.find_by_nonce(association_nonce)
    if association and Time.now < association.nonce_expiration_time
        user = User.find_by_slack_user_id(association.user_id)
        if not user
          # Expire the current association so the link stays one time use only.
          association.update_attributes(:nonce_expiration_time => Time.now)
          flash.now.alert = "Log in to link slack user to PostEvent"
          logout_user
          new_association_nonce = SecureRandom.hex()
          new_association = Associations.new(:user_id => association.user_id,
                                             :nonce => new_association_nonce,
                                             :nonce_expiration_time => 30.seconds.from_now)
          new_association.save
          session[:nonce] = new_association_nonce
          render "new"
          remove_nonce
        else
          association.update_attributes(:nonce_expiration_time => Time.now)
          session[:user_id] = user.id
          logger.debug("Redirect to root with user_id #{session[:user_id]}")
          redirect_to :controller => "events", :action => "new"
        end
    else
        logout_user
        render "slack_expired_nonce"
    end
  end

private
   def remove_nonce
    logger.debug("Remove nonce from session")
    session[:nonce] = nil
   end

   def logout_user
      session[:user_id] = nil
   end
end