class UsersController < ResourceController
  def resource_class
    User
  end
  
  def create_user
  end
  
  def validate_delete(resource)
    resource.events.empty? ? nil : 'Cannot delete User if he/she has events.'
  end
end