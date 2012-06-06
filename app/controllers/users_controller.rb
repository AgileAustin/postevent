class UsersController < ResourceController
  def create
    @password = (0...8).map{(65+rand(25)).chr}.join
    params[resource_parameter][:password] = @password
    params[resource_parameter][:password_confirmation] = @password
    if super
      UserMailer.registration_confirmation(@resource, @password).deliver 
    end
  end
  
  def resource_class
    User
  end
  
  def create_user
  end
  
  def validate_delete(resource)
    resource.events.empty? ? nil : 'Cannot delete User if he/she has events.'
  end
end