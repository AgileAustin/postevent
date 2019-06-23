require 'logger'

class UsersController < ResourceController
  STATE = 'f9183a6b975d3aeafeca228467b567' #A unique long string that is not easy to guess
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
    if Rails.configuration.meetup_consumer_key == nil || System.take.meetup_access_token
      logger.debug("User id in user#authorize #{session[:user_id]}")
      redirect_to START_URI
    else
      #Redirect your user in order to authenticate
      redirect_to client.auth_code.authorize_url(:scope => 'rw_groups', 
                                                 :state => STATE, 
                                                 :redirect_uri => ACCEPT_URI)
    end
  end
 
  # This method will handle the callback once the user authorizes your application
  def accept
    if !params[:state].eql?(STATE)
      #Reject the request as it may be a result of CSRF
      raise "Possible Cross Site Request Forgery Attempt"
    else
      token = client.auth_code.get_token(params[:code], :redirect_uri => ACCEPT_URI)
      current_user.update_attributes({:linkedin_token => token.token, :linkedin_token_expiration => DateTime.now + token.expires_in.seconds})
      redirect_to START_URI
    end
  end
  
private

  def client
    OAuth2::Client.new(
       Rails.configuration.linkedin_consumer_key, 
       Rails.configuration.linkedin_consumer_secret, 
       :authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
       :token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
       :site => "https://www.linkedin.com"
     )
  end
  
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