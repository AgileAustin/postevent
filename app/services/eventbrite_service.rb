class EventbriteService
  include HTTParty
  @@base_uri = 'https://www.eventbrite.com/xml/'
  
  def create_venue(location)
    if is_enabled
      params = get_location_params(location)
      params['organizer_id'] = Rails.configuration.eventbrite_organizer_id
      result = self.class.get(@@base_uri + 'venue_new', {:query => params})
      location.eventbrite_id = result['process']['id']
      location.save
    end
  end
  
  def update_venue(location)
    if is_enabled
      if location.eventbrite_id == nil
        create_venue(location)
      else
        params = get_location_params(location)
        params['id'] = location.eventbrite_id
        self.class.get(@@base_uri + 'venue_update', {:query => params})
      end
    end
  end

  def create_event(event)
    if is_enabled
      params = get_event_params(event)
      params['organizer_id'] = Rails.configuration.eventbrite_organizer_id
      result = self.class.get(@@base_uri + 'event_new', {:query => params})
      event.eventbrite_id = result['process']['id']
      event.save
      create_ticket(event)
    end
  end
  
  def create_ticket(event)
      params = get_ticket_params(event)
      result = self.class.get(@@base_uri + 'ticket_new', {:query => params})
      event.ticket_eventbrite_id = result['process']['id']
      event.save
  end
  
  def update_event(event)
    if is_enabled
      if event.eventbrite_id == nil
        create_event(event)
      else
        params = get_event_params(event)
        params['id'] = event.eventbrite_id
        self.class.get(@@base_uri + 'event_update', {:query => params})
        update_ticket(event)
      end
    end
  end
  
  def update_ticket(event)
      if event.ticket_eventbrite_id == nil
        create_ticket(event)
      else
        params = get_ticket_params(event)
        params['id'] = event.ticket_eventbrite_id
        self.class.get(@@base_uri + 'ticket_update', {:query => params})
      end
  end
  
private

  def is_enabled
    Rails.configuration.eventbrite_app_key != nil && Rails.configuration.eventbrite_user_key != nil
  end

  def get_location_params(location)
    params = get_params
    params['name'] = location.name
    params['address'] = location.address
    params['city'] = location.city
    params['region'] = location.state
    params['postal_code'] = location.postal_code
    params['country_code'] = Rails.configuration.default_country
    params
  end

  def get_event_params(event)
    params = get_params
    params['title'] = event.sig.name + " - " + event.title
    params['description'] = get_event_details(event)
    params['start_date'] = get_date_time(event.date, event.start)
    params['end_date'] = get_date_time(event.date, event.end)
    params['timezone'] = Rails.configuration.eventbrite_timezone
    params['privacy'] = 1
    params['venue_id'] = event.location.eventbrite_id
    params['capacity'] = event.capacity
    params['status'] = 'live'
    params
  end

  def get_ticket_params(event)
    params = get_params
    params['event_id'] = event.eventbrite_id
    params['name'] = "Free Ticket"
    params['price'] = "0.00"
    params['quantity_available'] = event.capacity
    params['end_date'] = get_date_time(event.date, event.start)
    params
  end
  
  def get_date_time(date, time)
    date.year.to_s + '-' + to_double_digit(date.month) + '-' + to_double_digit(date.day) + ' ' +
      to_double_digit(time.hour) + ':' + to_double_digit(time.min) + ':' + to_double_digit(time.sec)
  end
  
  def to_double_digit(number)
    (number < 10 ? '0' : '') + number.to_s
  end
  
  def get_event_details(event)
    result =
      "<b>Topic: #{event.title}</b><br/>" +
      "<br/>"
    event.description.split("\n").each do |str|
      result += str + "<br/>"
    end
    if !event.speaker.strip.empty?
      result += 
        "<br/>" +
        "<b>Speaker: #{event.speaker}</b><br/>"
      if !event.speaker_bio.strip.empty?
        result += "<br/>"
        event.speaker_bio.split("\n").each do |str|
          result += str + "<br/>"
        end
      end
    end
    result +=
      "<br/>" +
      "<b><u>#{event.sig.name} Info:</u></b><br/><ul>"
    if !event.sig.google_group.strip.empty?
      result +=
        "<li>More information and communication may be found at the SIG's Google Group: <a href='#{event.sig.google_group}'>#{event.sig.google_group}</a>.</li>"
    end
    result +=
      "<li>Food and Drink will be provided courtesy of #{event.food_sponsor}.</li></ul>"
    if !event.location.directions.strip.empty?
      result +=
        "<br/>" +
        "<b><u>Directions and Parking Info:</u></b><br/>" +
        "<br/>"
      event.location.directions.split("\n").each do |str|
        result += str + "<br/>"
      end
    end
    result +=
      "<br/>" +
      "<b>Seating is limited!</b><br/>" +
      "<br/>" +
      "Please make sure that you are able to attend this session.  Seating is limited and on a first-come, first-served basis.  We want to give everyone the opportunity to attend, so please only sign up if you are committed to attending.<br/>"
    if !event.sig.email.strip.empty?
      result +=
        "<br/>" +
        "For more information/questions, please send email to: <a href='mailto:#{event.sig.email}'>#{event.sig.email}</a>.<br/>"
    end
  end

  def get_params
    {:app_key => Rails.configuration.eventbrite_app_key, :user_key => Rails.configuration.eventbrite_user_key }
  end
end