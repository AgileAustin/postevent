class MeetupService < Service
  require "./app/utils/formatter.rb"
  include HTTParty
  @@base_uri = 'http://api.meetup.com/'
  
  def get_authorization_url(redirect_url)
  	"https://secure.meetup.com/oauth2/authorize?client_id=#{Rails.configuration.meetup_consumer_key}&response_type=code&redirect_uri=#{redirect_url}"
  end
 
  def authorize(code, redirect_url)
  	result = self.class.post("https://secure.meetup.com/oauth2/access", {
  		body: "client_id=#{Rails.configuration.meetup_consumer_key}&client_secret=#{Rails.configuration.meetup_consumer_secret}&grant_type=authorization_code&redirect_uri=#{redirect_url}&code=#{code}"
  		headers: {
  			'Content-Type' => 'application/x-www-form-urlencoded',
  			'charset' => 'utf-8'
  		}
  	)
  	puts result
  	if result['error']
  		false
  	else
  		system = System.take
  		system.meetup_access_token = result['access_token']
  		system.meetup_refresh_token = result['refresh_token']
  		system.save()
  		true
  	end
  end
  
  def create_venue(location)
    if is_enabled
      params = get_location_params(location)
      result = post(@@base_uri + Rails.configuration.meetup_group_urlname + "/venues", params)
      if result['errors']
        raise result['errors'][0]['message']
      end
      location.meetup_id = result['id']
      location.save
    end
  end
  
  def update_venue(location)
    if location.events.size > 0
      create_venue(location) # cannot update
      location.events.each {|event| update_event(event)}
    end
  end

  def create_event(event, announce=false)
    if is_enabled
      if event.location.meetup_id == nil
        create_venue(event.location)
      end
      params = get_event_params(event)
      params['self_rsvp'] = false
      result = post(@@base_uri + Rails.configuration.meetup_group_urlname + '/events', params)
      if result['details']
        raise result['details']
      end
      event.meetup_id = result['id']
      event.save
      if announce
        update_event(event, true)
      end
    end
  end
  
  def update_event(event, announce=false)
    if is_enabled
      if event.location.meetup_id == nil
        create_venue(event.location)
      end
      if event.meetup_id == nil
        create_event(event)
      else
        params = get_event_params(event)
        if announce
	        params[:query]['announce'] = true
	    end
        result = patch(@@base_uri + Rails.configuration.meetup_group_urlname + '/events/' + event.meetup_id, params)
        if result['details']
          raise result['details']
        end
      end
    end
  end
  
private
 
  def post(url, params)
    result = self.class.post(url, params)
    puts result
    if result.code == 401
      if refresh_token()
        result = self.class.patch(url, params)
        puts result
      end
    end
    result
f  end
 
  def patch(url, params)
    result = self.class.patch(url, params)
    puts result
    if result.code == 401
      if refresh_token()
        result = self.class.patch(url, params)
        puts result
      end
    end
    result
  end
 
  def refresh_token()
    system = System.take
  	refresh_token = system.meetup_refresh_token
  	result = self.class.post("https://secure.meetup.com/oauth2/access", {
  		body: "client_id=#{Rails.configuration.meetup_consumer_key}&client_secret=#{Rails.configuration.meetup_consumer_secret}&grant_type=refresh_token&refresh_token=#{refresh_token}"
  		headers: {
  			'Content-Type' => 'application/x-www-form-urlencoded',
  			'charset' => 'utf-8'
  		}
  	)
  	puts result
  	if result['error']
  		false
  	else
  		system.meetup_access_token = result['access_token']
  		system.meetup_refresh_token = result['refresh_token']
  		system.save()
  		true
  	end
  end

  def is_enabled
    Rails.configuration.meetup_apikey != nil
  end

  def get_location_params(location)
    params = get_params
    params[:query] = {
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
      'name' => event.group_title,
      'description' => get_event_details(event),
      'venue_id' => event.location.meetup_id,
      'rsvp_limit' => event.capacity,
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
            'Accept' => 'application/json',
            'Authorization' => 'Bearer ' + System.take.meetup_access_token
        }
    }
  end
end