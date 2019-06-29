require 'logger'

class UsersController < ResourceController
  AUTHORIZE_URI = Rails.configuration.post_url + '/authorize'
  ACCEPT_URI = Rails.configuration.post_url + '/accept'
  START_URI = Rails.configuration.post_url + '/events/new'

  def create
    @password = random_password
    params[resource_parameter][:password] = @password
    params[resource_parameter][:password_confirmation] = @password
    if super
      UserMailer.registration_confirmation(@resource, @password).deliver 
    end
  end
  
  def reset_password
    @resource = resource_class.find(params[:id])
    @password = random_password
    @resource.password = @password
    @resource.password_confirmation = @password
    @resource.save
    UserMailer.registration_confirmation(@resource, @password).deliver 
    flash[:notice] = "Password has been reset.  New password has been emailed to user."
    redirect_to :action => "index"
  end

# Oauth authorization

  def authorize
    if Rails.configuration.meetup_consumer_key == nil || System.first.meetup_access_token
      logger.debug("User id in user#authorize #{session[:user_id]}")
      redirect_to START_URI
	else
      #Redirect your user in order to authenticate
      redirect_to MeetupService.new.get_authorization_url(ACCEPT_URI)
    end
  end
 
  # This method will handle the callback once the user authorizes your application
  def accept
    if params[:error]
      redirect_to AUTHORIZE_URI
    else
      if MeetupService.new.authorize(params[:code], ACCEPT_URI)
        redirect_to START_URI
      else
      	redirect_to_AUTHORIZE_URI
      end
    end
  end
  
private
  
  def random_password
    (0...8).map{(65+rand(25)).chr}.join
  end
  
  def resource_class
    User
  end
  
  def order_by
    'email'
  end
  
  def create_user
  end
  
  def validate_delete(resource)
    (resource.events == nil || resource.events.empty?) ? nil : 'Cannot delete User if he/she has events.'
  end
end