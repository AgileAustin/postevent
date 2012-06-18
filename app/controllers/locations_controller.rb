class LocationsController < ResourceController
  def create
    if super
      EventbriteService.new.create_venue(@resource)
    end
  end

  def update
    if super
      EventbriteService.new.update_venue(@resource)
    end
  end

  def resource_class
    Location
  end
  
  def validate_delete(resource)
    resource.events.empty? ? nil : 'Cannot delete Location if it has events.'
  end
  
  def new_resource
    @resource = super
    @resource.city = Rails.configuration.default_city
    @resource.state = Rails.configuration.default_state
    @resource
  end  
end
