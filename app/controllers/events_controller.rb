class EventsController < ResourceController
  def create
    params[resource_parameter][:user_id] = current_user.id
    if super
      errors = []
      EventbriteService.new.create(@resource, errors)
      ManualMailer.event_submitted(@resource, {:prefix => "Posted: "}).deliver 
      GoogleCalendarService.new.create(@resource, errors)
      if Rails.configuration.community_email
        CommunityMailer.event_submitted(@resource).deliver
      end
      TwitterService.new.create(@resource, errors)
      WordpressService.new.create(@resource, errors)
      if !errors.empty?
        ErrorMailer.errors(errors, "Posting").deliver
      end
    end
  end

  def edit
    @is_change = true
    super
  end

  def update
    if super
      errors = []
      EventbriteService.new.update(@resource, errors)
      ManualMailer.event_submitted(@resource, {:prefix => "Updated: "}).deliver 
      GoogleCalendarService.new.update(@resource, errors)
      if params[:update_mailing_list]
        if Rails.configuration.community_email
          CommunityMailer.event_submitted(@resource, {:prefix => "Updated: "}).deliver 
        end
        TwitterService.new.update(@resource, errors)
      end
      if !errors.empty?
        ErrorMailer.errors(errors, "Updating").deliver
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