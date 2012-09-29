class EventsController < ResourceController
  def create
    params[resource_parameter][:user_id] = current_user.id
    if super
      errors = []
      EventbriteService.new.create(@resource, errors)
      ManualMailer.event_submitted(@resource, {:prefix => "Posted: "}).deliver 
      GoogleCalendarService.new.create(@resource, errors)
      WordpressService.new.create(@resource, errors)
      if params[:update_mailing_list]
        if Rails.configuration.community_email
          CommunityMailer.event_submitted(@resource).deliver
        end
        TwitterService.new.create(@resource, errors)
        LinkedinService.new.create(@resource, errors)
      end
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
      WordpressService.new.update(@resource, errors)
      if params[:update_mailing_list]
        if Rails.configuration.community_email
          CommunityMailer.event_submitted(@resource, {:prefix => "Updated: "}).deliver 
        end
        TwitterService.new.update(@resource, errors)
        LinkedinService.new.update(@resource, errors)
      end
      if !errors.empty?
        ErrorMailer.errors(errors, "Updating").deliver
      end
    end
  end

private

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
  
  def created_message
    super + " Posted to Eventbrite, mailing list, Google calendar, web site, Twitter and LinkedIn."
  end
  
  def updated_message
    super + " Updated on Eventbrite, Google calendar and web site." + (params[:update_mailing_list] ? " Reposted to mailing list, Twitter and LinkedIn." : "")
  end
end