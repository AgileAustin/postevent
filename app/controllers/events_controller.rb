require 'logger'

class EventsController < ResourceController
  def new
    warn_not_authenticated
    super
  end
  
  def create
    params[resource_parameter][:user_id] = current_user.id
    if super
      errors = []
      EventbriteService.new.create(@resource, errors)
      MeetupService.new.create(@resource, errors, nil, params[:update_mailing_list])
      ManualMailer.event_submitted(@resource, {:prefix => "Posted: "}).deliver 
      GoogleCalendarService.new.create(@resource, errors)
      WordpressService.new.create(@resource, errors)
      if params[:update_mailing_list]
        if Rails.configuration.community_email
          CommunityMailer.event_submitted(@resource).deliver
        end
        TwitterService.new.create(@resource, errors)
      end
      if !errors.empty?
        ErrorMailer.errors(errors, "Posting").deliver
      end
    end
  end

  def edit
    @is_change = true
    warn_not_authenticated
    super
  end

  def update
    if super
      errors = []
      EventbriteService.new.update(@resource, errors)
      MeetupService.new.update(@resource, errors)
      ManualMailer.event_submitted(@resource, {:prefix => "Updated: "}).deliver 
      GoogleCalendarService.new.update(@resource, errors)
      WordpressService.new.update(@resource, errors)
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

  def warn_not_authenticated
    logger.debug("events#warn_not_authenticated user id #{session[:user_id]}")
    if Rails.configuration.meetup_consumer_key != nil && !System.first.meetup_access_token
      flash[:unauthorized] = 'Warning: You have not authorized Postevent to post to MeetUp.'
    end
  end
  
  def created_message
    super + " Posted to Meetup" + (params[:update_mailing_list] ? ", Google calendar, Twitter and mailing list." : " and Google calendar.")
  end
  
  def updated_message
    super + " Updated on Meetup and Google calendar." + (params[:update_mailing_list] ? " Reposted to Twitter and mailing list." : "")
  end
end