class LinkedinService < Service
  require "app/utils/formatter.rb"
  require "linkedin"

  def create_event(event)
    post_event(event)
  end

  def update_event(event)
    post_event(event, 'Updated: ')
  end

private
  
  def post_event(event, prefix='')
    if Rails.configuration.linkedin_consumer_key
      params = {
        'title' => prefix + event.group_title,
        'summary' => get_event_details(event)
      }
      
      client = LinkedIn::Client.new(Rails.configuration.linkedin_consumer_key, Rails.configuration.linkedin_consumer_secret)
      client.authorize_from_access(Rails.configuration.linkedin_oauth_token, Rails.configuration.linkedin_oauth_token_secret)
      json_txt = client.post_to_group(Rails.configuration.linkedin_group_id, params)
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