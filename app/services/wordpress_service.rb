class WordpressService < Service
  # Note: This service requires the Wordpress site to have the JSON API plugin and the Event Calendar plugin.
  # It also needs this change to the plugin: https://github.com/Achillefs/wp-json-api/commit/7d1f8b4f963c4080a4f8923951e24e5b65740117
  # It also requires the changes detailed at the bottom of this file
  
  require "app/utils/formatter.rb"
  include HTTParty

  @@base_uri = Rails.configuration.wordpress_base_url
  
  def create_event(event)
    if is_enabled
      params = get_event_params(event)
      params['nonce'] = get_main_nonce
      params['author'] = Rails.configuration.wordpress_username
      params['user_password'] = Rails.configuration.wordpress_password
      self.class.get(@@base_uri + 'create_post', :query => params)
    end
  end
  
private

  def get_main_nonce
      params = {:controller => 'posts', :method => 'create_post'}
      result = self.class.get(@@base_uri + 'get_nonce', :query => params)
      result['nonce']
  end

  def get_ec3_nonce
      params = {:controller => 'event-calendar/admin.php'}
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
    params['ec3_nonce'] = get_ec3_nonce
    params['ec3_action__0'] = "create"
    params['ec3_start__0'] = format_date(event.date) + " " + format_time(event.start)
    params['ec3_end__0'] = format_date(event.date) + " " + format_time(event.end)
    params['ec3_action__'] = "create"
    params['ec3_start__'] = format_date(event.date) + " " + format_time(event.start)
    params['ec3_end__'] = format_date(event.date) + " " + format_time(event.end)
    params['ec3_rows'] = 1
    params
  end
  
  def format_date(date)
    date.year.to_s + "-" + (date.month<10 ? '0' : '') + date.month.to_s + "-" + (date.day<10 ? '0' : '') + date.day.to_s
  end
  
  def format_time(time) # For some reason strftime isn't working here
    (time.hour < 10 ? '0' : '') + time.hour.to_s + ':' + (time.min < 10 ? '0' : '') + time.min.to_s
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
    result += "To Register (and for more info): <a href='#{event.eventbrite_url}'>#{event.eventbrite_url}</a>.<br/>"
  end
end

=begin
  Replace the version of get_nonce() in plugins/json-api/controllers/core.php with:

  public function get_nonce() {
    global $json_api;
    extract($json_api->query->get(array('controller', 'method')));
    if ($controller && $method) {
      $controller = strtolower($controller);
      if (!in_array($controller, $json_api->get_controllers())) {
        $json_api->error("Unknown controller '$controller'.");
      }
      require_once $json_api->controller_path($controller);
      if (!method_exists($json_api->controller_class($controller), $method)) {
        $json_api->error("Unknown method '$method'.");
      }
      $nonce_id = $json_api->get_nonce_id($controller, $method);
      return array(
        'controller' => $controller,
        'method' => $method,
        'nonce' => wp_create_nonce($nonce_id)
      );
    } else if ($controller) {
      return array(
        'controller' => $controller,
        'nonce' => wp_create_nonce($controller)
      );
    } else {
      $json_api->error("Include 'controller' and 'method' vars in your request.");
    }
  }
  
  Add the following to save() in plugins/json-api/models/post.php right before the call to wp_update_post($wp_values);
    // Added to add fields used by other plug-ins
    foreach($values as $key => $value){
      if(strlen(strstr($key,'id'))==0 &&
        strlen(strstr($key,'type'))==0 &&
        strlen(strstr($key,'status'))==0 &&
        strlen(strstr($key,'title'))==0 &&
        strlen(strstr($key,'content'))==0 &&
        strlen(strstr($key,'author'))==0 &&
        strlen(strstr($key,'categories'))==0 &&
        strlen(strstr($key,'tags'))==0)//it must be a custom_field, so add it
      $_POST[$key] = $value;
    }
=end