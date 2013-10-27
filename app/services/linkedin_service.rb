class LinkedinService < Service
  require "./app/utils/formatter.rb"
  require "linkedin-oauth2"

  def create_event(user, event)
    post_event(user, event)
  end

  def update_event(user, event)
    post_event(user, event, 'Updated: ')
  end

private
  
  def post_event(user, event, prefix='')
    if Rails.configuration.linkedin_consumer_key    
      params = {
        'title' => prefix + event.group_title,
        'summary' => get_event_details(event)
      }
      
      client = LinkedIn::Client.new(Rails.configuration.linkedin_consumer_key, Rails.configuration.linkedin_consumer_secret, user.linkedin_token)
      client.post_to_group(Rails.configuration.linkedin_group_id, params)
    end
  end
  
  def get_event_details(event)
    formatter = Formatter.new
    result = event.description
    result += "\n"
    if !event.speaker.strip.empty?
      result +=
        "\nSpeaker: #{event.speaker}\n"
    end
    result += "\nDate/Time: #{formatter.format_date(event.date)} #{formatter.format_time(event.start)} - #{formatter.format_time(event.end)}\n\n"
    result += "Venue: #{event.location.name_and_address}\n\n"
    result += "To Register (and for more info): #{event.eventbrite_url}.\n"
  end
end