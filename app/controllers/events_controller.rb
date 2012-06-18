class EventsController < ResourceController
  def create
    params[resource_parameter][:user_id] = current_user.id
    if super
      EventbriteService.new.create_event(@resource)
      EventMailer.event_submitted(@resource).deliver 
    end
  end

  def update
    if super
      EventbriteService.new.update_event(@resource)
    end
  end

  def resource_class
    Event
  end
  
  def order_by
    'date, start'
  end

  def new_resource
    @resource = super
    @resource.food_sponsor = Rails.configuration.default_food_sponsor
    @resource.start = Time.local(2012,1,1,12,0)
    @resource.end = Time.local(2012,1,1,13,0)
    @resource
  end  
end