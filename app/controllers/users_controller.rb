class UsersController < ResourceController
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
    resource.events.empty? ? nil : 'Cannot delete User if he/she has events.'
  end
end