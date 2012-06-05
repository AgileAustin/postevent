class LocationsController < ResourceController
  def resource_class
    Location
  end
  
  def validate_delete(resource)
    resource.events.empty? ? nil : 'Cannot delete Location if it has events.'
  end
end
