class MeetupService < Service
  require "./app/utils/formatter.rb"
  include HTTParty
  @@base_uri = 'http://api.meetup.com/'
  
  def create_venue(location)
    if is_enabled
      params = get_location_params(location)
      result = self.class.post(@@base_uri + Rails.configuration.meetup_group_urlname + '/venues', params)
      puts result
      if result['errors']
        raise result['errors'][0]['message']
      end
      location.meetup_id = result['id']
      location.save
    end
  end
  
  def update_venue(location)
    create_venue(location) # cannot update
  end

  def create_event(event)
    if is_enabled
      if event.location.meetup_id == nil
        create_venue(event.location)
      end
      params = get_event_params(event)
      result = self.class.post(@@base_uri + '2/event', params)
      puts result
      if result['details']
        raise result['details']
      end
      event.meetup_id = result['id']
      event.save
      update_event(event)
    end
  end
  
  def update_event(event)
    if is_enabled
      if event.location.meetup_id == nil
        create_venue(event.location)
      end
      if event.meetup_id == nil
        create_event(event)
      else
        params = get_event_params(event)
        params[:query]['announce'] = true
        result = self.class.post(@@base_uri + '2/event/' + event.meetup_id, params)
        if result['details']
          raise result['details']
        end
      end
    end
  end
  
private

  def is_enabled
    Rails.configuration.meetup_apikey != nil
  end

  def get_location_params(location)
    params = get_params
    params[:query] = {
      'key' => Rails.configuration.meetup_apikey,
      'address_1' => location.address,
      'address_2' => location.address2,
      'city' => location.city,
      'country' => Rails.configuration.default_country,
      'name' => location.name,
      'state' => location.state
    }
    puts params
    params
  end

  def get_event_params(event)
    offset = Time.use_zone(Rails.configuration.timezone) {event.date.to_time.in_time_zone.dst?} ? Rails.configuration.timezone_offset_dst : Rails.configuration.timezone_offset
    params = get_params
    params[:query] = {
      'key' => Rails.configuration.meetup_apikey,
      'group_id' => Rails.configuration.meetup_group_id,
      'group_urlname' => Rails.configuration.meetup_group_urlname,
      'name' => event.group_title,
      'description' => get_event_details(event),
      'venue_id' => event.location.meetup_id,
      'rsvp_limit' => event.capacity,
      'waitlisting' => 'auto',
      'guest_limit' => 0,
      'time' => DateTime.new(event.date.year, event.date.month, event.date.day, event.start.hour, event.start.min, event.start.sec, offset).strftime('%Q').to_i,
      'duration' => (event.end - event.start).to_i * 1000
    }
    puts params
    params
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
        :headers => {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
        }
    }
  end
end