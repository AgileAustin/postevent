class EventbriteService < Service
  require "./app/utils/formatter.rb"
  include HTTParty
  @@base_uri = 'https://www.eventbriteapi.com/v3/'
  
  def create_venue(location)
    if is_enabled
      params = get_location_params(location)
      result = self.class.post(@@base_uri + 'venues/', params)      
      if result['error_description']
        raise result['error_description']
      end
      location.eventbrite_id = result['id']
      location.save
    end
  end
  
  def update_venue(location)
    create_venue(location) # cannot update
  end

  def create_event(event)
    if is_enabled
      params = get_event_params(event)
      result = self.class.post(@@base_uri + 'events/', params)
      if result['error_description']
        raise result['error_description']
      end
      event.eventbrite_id = result['id']
      event.save
      create_ticket(event)
      publish_event(event)
    end
  end
  
  def create_ticket(event)
      params = get_ticket_params(event)
      result = self.class.post(@@base_uri + 'events/' + event.eventbrite_id + '/ticket_classes/', params)
      if result['error_description']
        raise result['error_description']
      end
      event.ticket_eventbrite_id = result['id']
      event.save
  end
  
  def publish_event(event)
      result = self.class.post(@@base_uri + 'events/' + event.eventbrite_id + '/publish/', get_params)
      if result['error_description']
        raise result['error_description']
      end
  end
  
  def update_event(event)
    if is_enabled
      if event.eventbrite_id == nil
        create_event(event)
      else
        params = get_event_params(event)
        result = self.class.post(@@base_uri + 'events/' + event.eventbrite_id + '/', params)
        if result['error_description']
          raise result['error_description']
        end
        update_ticket(event)
      end
    end
  end
  
  def update_ticket(event)
      if event.ticket_eventbrite_id == nil
        create_ticket(event)
      else
        params = get_ticket_params(event)
        result = self.class.post(@@base_uri + 'events/' + event.eventbrite_id + '/ticket_classes/' + event.ticket_eventbrite_id + '/', params)
        if result['error_description']
          raise result['error_description']
        end
      end
  end
  
private

  def is_enabled
    Rails.configuration.eventbrite_token != nil
  end

  def get_location_params(location)
    params = get_params
    params[:body] = {
      'venue' => {
        'name' => location.name,
        'address' => {
          'address_1' => location.address,
          'address_2' => location.address2,
          'city' => location.city,
          'region' => location.state,
          'postal_code' => location.postal_code,
          'country' => Rails.configuration.default_country
        }
      }
    }.to_json
    params
  end

  def get_event_params(event)
    params = get_params
    params[:body] = {
      'event' => {
        'name' => {
          'html' => event.group_title
        },
        'description' => {
          'html' => get_event_details(event)
        },
        'start' => {
          'timezone' => Rails.configuration.timezone,
          'utc' => get_date_time(event.date, event.start)
        },
        'end' => {
          'timezone' => Rails.configuration.timezone,
          'utc' => get_date_time(event.date, event.end)
        },
        'currency' => 'USD',
        'venue_id' => event.location.eventbrite_id,
        'capacity' => event.capacity,
        'listed' => true,
        'shareable' => true,
        'invite_only' => false,
        'organizer_id' => Rails.configuration.eventbrite_organizer_id
      }
    }.to_json
    params
  end

  def get_ticket_params(event)
    params = get_params
    params[:body] = {
      'ticket_class' => {
        'name' => "Free Ticket",
        'quantity_total' => event.capacity,
        'free' => true,
        'maximum_quantity' => 1
      }
    }.to_json
    params
  end
  
  def get_date_time(date, time)
    offset = (Time.use_zone(Rails.configuration.timezone) {date.to_time.in_time_zone.dst?} ? Rails.configuration.timezone_offset_dst : Rails.configuration.timezone_offset).to_i
    if time.hour - offset >= 24
      date = date + 1
    elsif time.hour - offset < 0
      date = date - 1
    end
    time = time - offset * 60 * 60
    date.year.to_s + '-' + to_double_digit(date.month) + '-' + to_double_digit(date.day) + 'T' +
      to_double_digit(time.hour) + ':' + to_double_digit(time.min) + ':' + to_double_digit(time.sec) + 'Z'
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
    result += ' ' # Unclear why this is necessary, but the description won't post without it
  end

  def get_params
    {
        :query => {
            'token' => Rails.configuration.eventbrite_token
        },
        :headers => {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
        }
    }
  end
end
