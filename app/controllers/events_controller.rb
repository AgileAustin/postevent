class EventsController < ResourceController
  def create
    params[resource_parameter][:user_id] = current_user.id
    if super
      ManualMailer.event_submitted(@resource, {:prefix => "Posted: "}).deliver 
      EventbriteService.new.create_event(@resource)
      BlogMailer.event_submitted(@resource).deliver 
      CommunityMailer.event_submitted(@resource).deliver
      GoogleCalendarService.new.create_event(@resource)
      TwitterService.new.create_event(@resource)
    end
  end

  def edit
    @is_change = true
    super
  end

  def update
    if super
      ManualMailer.event_submitted(@resource, {:prefix => "Updated: "}).deliver 
      EventbriteService.new.update_event(@resource)
      GoogleCalendarService.new.update_event(@resource)
      if params[:update_mailing_list]
        CommunityMailer.event_submitted(@resource, {:prefix => "Updated: "}).deliver 
        TwitterService.new.update_event(@resource)
      end
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