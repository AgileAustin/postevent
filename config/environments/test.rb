Postevent::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
  
  # Application specific configuration
  config.email_contact = "noreply@gmail.com"
  config.organization = "postevent"
  config.timezone = "America/Chicago"
  config.timezone_offset = "-06"
  config.timezone_offset_dst = "-05"
  config.post_url = "http://www.postevent.com"
  config.blog_url = "http://blog.postevent.com"
  config.calendar_url = "http://calendar.postevent.com"
  config.default_food_sponsor = "Our Sponsor"
  config.default_city = "Austin"
  config.default_state = "TX"
  config.default_country = "US"
  config.eventbrite_app_key = nil
  config.eventbrite_user_key = nil
  config.eventbrite_organizer_id = nil
  config.meetup_apikey = nil
  config.meetup_group_id = nil
  config.meetup_group_urlname = nil
  config.community_email = nil
  config.twitter_consumer_key = nil
  config.twitter_consumer_secret = nil
  config.twitter_oauth_token = nil
  config.twitter_oauth_token_secret = nil
  config.google_calendar_id = nil
  config.google_api_client_secret = nil
  config.google_api_client_id = nil
  config.google_api_refresh_token = nil
  config.google_api_access_token = nil
  config.wordpress_username = nil
  config.wordpress_password = nil
  config.wordpress_old_base_url = nil
  config.wordpress_base_url = nil # example http://www.example.com/api/
  config.wordpress_category = nil
  config.linkedin_consumer_key = nil
  config.linkedin_consumer_secret = nil
  config.linkedin_group_id = nil
end