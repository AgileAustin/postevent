class GoogleCalendarService < Service
  require 'google/api_client'
  
  def create_event(event)
    if is_enabled
      placeholder = get_existing_event(event)
      if placeholder != nil && Event.where(:google_id => placeholder).empty?
        delete_existing_event(placeholder)
      end

      client = get_client
      service = get_service(client)
      result = client.execute(:api_method => service.events.insert,
        :parameters => {'calendarId' => Rails.configuration.google_calendar_id},
        :body => JSON.dump(get_event(event)),
        :headers => {'Content-Type' => 'application/json'})
      event.google_id = result.data.id
      event.save
    end
  end
  
  def update_event(event)
    if is_enabled
      if event.google_id == nil
        create_event(event)
      else
        client = get_client
        service = get_service(client)
        client.execute(:api_method => service.events.update,
          :parameters => {
            'calendarId' => Rails.configuration.google_calendar_id,
            'eventId' => event.google_id
          },
          :body => JSON.dump(get_event(event)),
          :headers => {'Content-Type' => 'application/json'})
      end
    end
  end
    
private

  def get_existing_event(event)
    client = get_client
    service = get_service(client)
    result = client.execute(:api_method => service.events.list,
      :parameters => {
        'calendarId' => Rails.configuration.google_calendar_id,
        'q' => event.sig.name,
        'singleEvents' => 'true',
        'timeMin' => get_date_time(event.date - 7, event.start),
        'timeMax' => get_date_time(event.date + 7, event.start)
      },
      :headers => {'Content-Type' => 'application/json'})
    if result.data.items.length != 1
      nil
    else
      result.data.items[0].id
    end
  end

  def delete_existing_event(eventId)
    client = get_client
    service = get_service(client)
    client.execute(:api_method => service.events.delete,
      :parameters => {
        'calendarId' => Rails.configuration.google_calendar_id,
        'eventId' => eventId
      },
      :headers => {'Content-Type' => 'application/json'})
  end

  def is_enabled
    Rails.configuration.google_calendar_id != nil
  end
  
  def get_client
    client = Google::APIClient.new
    client.authorization.client_id = Rails.configuration.google_api_client_id
    client.authorization.client_secret = Rails.configuration.google_api_client_secret
    client.authorization.scope = "https://www.googleapis.com/auth/calendar"
    client.authorization.refresh_token = Rails.configuration.google_api_refresh_token
    client.authorization.access_token = Rails.configuration.google_api_access_token
    
    if client.authorization.refresh_token && client.authorization.expired?
      client.authorization.fetch_access_token!
    end
    client
  end
  
  def get_service(client)
    client.discovered_api('calendar', 'v3')  
  end

  def get_event(event)
    {
      'summary' => event.group_title,
      'description' => get_event_details(event),
      'location' => event.location.name_and_address,
      'start' => {
        'dateTime' => get_date_time(event.date, event.start)
      },
      'end' => {
        'dateTime' => get_date_time(event.date, event.end)
      },
      'attendees' => []
    }
  end
  
  def get_date_time(date, time) # ex:" '2011-06-03T10:00:00.000-07:00'
    date.year.to_s + '-' + to_double_digit(date.month) + '-' + to_double_digit(date.day) + 'T' +
      to_double_digit(time.hour) + ':' + to_double_digit(time.min) + ':' + to_double_digit(time.sec) + ".000" +
      (Time.use_zone(Rails.configuration.timezone) {date.to_time.in_time_zone.dst?} ? Rails.configuration.timezone_offset_dst : Rails.configuration.timezone_offset) + ":00"
  end
  
  def to_double_digit(number)
    (number < 10 ? '0' : '') + number.to_s
  end
  
  def get_event_details(event)
    result = event.description + "\n"
    if !event.speaker.strip.empty?
      result += 
        "\n" +
        "Speaker: #{event.speaker}\n"
    end
    result += 
      "\n" +
      "To Register (and for more info):\n" +
      "<a href='#{event.meeting_url}'>#{event.meeting_url}</a>"
  end
end