class WordpressService
  # Note: This service requires the Wordpress site to have the JSON API plugin.
  # It also needs this change to the plugin: https://github.com/Achillefs/wp-json-api/commit/7d1f8b4f963c4080a4f8923951e24e5b65740117
  
  require "app/utils/formatter.rb"
  include HTTParty

  @@base_uri = Rails.configuration.wordpress_base_url
  
  def create_event(event)
    if is_enabled
      params = get_event_params(event)
      params['nonce'] = get_nonce
      params['author'] = Rails.configuration.wordpress_username
      params['user_password'] = Rails.configuration.wordpress_password
      self.class.get(@@base_uri + 'create_post', :query => params)
    end
  end
  
private

  def get_nonce
      params = {:controller => 'posts', :method => 'create_post'}
      result = self.class.get(@@base_uri + 'get_nonce', :query => params)
      result['nonce']
  end

  def is_enabled
    Rails.configuration.wordpress_username != nil && Rails.configuration.wordpress_password != nil
  end

  def get_event_params(event)
    params = {}
    params['status'] = 'publish'
    params['title'] = event.group_title
    params['content'] = get_event_details(event)
    params['categories'] = "#{Rails.configuration.wordpress_category},#{event.sig.wordpress_category}"
    params
  end

  def get_event_details(event)
    formatter = Formatter.new
    result = ''
    event.description.split("\n").each do |str|
      result += str + '<br/>'
    end
    if !event.speaker.strip.empty?
      result +=
        "<br/>Speaker: #{event.speaker}<br/>"
    end
    result += "<br/>Date/Time: #{formatter.format_date(event.date)} #{formatter.format_time(event.start)} - #{formatter.format_time(event.end)}<br/><br/>"
    result += "Venue: #{event.location.name_and_address}<br/><br/>"
    result += "To Register (and for more info): <a href='http://www.eventbrite.com/event/#{event.eventbrite_id}'>http://www.eventbrite.com/event/#{event.eventbrite_id}</a>.<br/>"
  end
end