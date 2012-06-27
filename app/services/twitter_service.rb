class TwitterService < Service
  require "app/utils/formatter.rb"
  include Twitter
  
  Twitter.configure do |config|
    config.consumer_key = Rails.configuration.twitter_consumer_key
    config.consumer_secret = Rails.configuration.twitter_consumer_secret
    config.oauth_token = Rails.configuration.twitter_oauth_token
    config.oauth_token_secret = Rails.configuration.twitter_oauth_token_secret
  end

  def create_event(event)
    if is_enabled
      Twitter.update(tweet(event))
    end
  end

  def update_event(event)
    if is_enabled
      Twitter.update(tweet(event, "Updated :"))
    end
  end
  
  def tweet(event, prefix='')
    formatter = Formatter.new
    first_part = prefix + event.sig.name + " - "
    last_part = " - #{formatter.format_date(event.date)} - #{event.eventbrite_url}"
    max_size = 140 - first_part.length - last_part.length
    middle = event.title.length>max_size ? (event.title[0..(max_size - 4)] + '...') : event.title
    first_part + middle + last_part 
  end

private

  def is_enabled
    Rails.configuration.twitter_consumer_key != nil
  end
end