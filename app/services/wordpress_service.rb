class WordpressService < Service
  # Note: This service requires the Wordpress site to have the JSON API plugin and optionally the Event Calendar plugin.
  # It also requires the changes detailed at the bottom of this file
  
  require "./app/utils/formatter.rb"
  include HTTParty

  @@base_uri = Rails.configuration.wordpress_base_url
  
  def create_event(event)
    if is_enabled
      if Rails.configuration.wordpress_old_base_url != nil
        self.class.get(Rails.configuration.wordpress_old_base_url + 'create_post', :query => get_params(event, Rails.configuration.wordpress_old_base_url, 'create_post'))
      end
      response = self.class.get(@@base_uri + 'create_post', :query => get_params(event, @@base_uri, 'create_post'))
      event.wordpress_id = response['post']['id']
      event.save
    end
  end
  
  def update_event(event)
    if is_enabled
      if (event.wordpress_id)
        params = get_params(event, @@base_uri, 'update_post')
        params['id'] = event.wordpress_id
        self.class.get(@@base_uri + 'posts/update_post', :query => params)
      else
        create_event(event)
      end
    end
  end
  
private

  def get_params(event, uri, method)
    params = get_event_params(event)
    params['nonce'] = get_main_nonce(uri, method)
    params['user_name'] = Rails.configuration.wordpress_username
    params['user_password'] = Rails.configuration.wordpress_password
    params['author'] = Rails.configuration.wordpress_username
    params
  end

  def get_main_nonce(uri, method)
      params = {:controller => 'posts', :method => method}
      result = self.class.get(uri + 'get_nonce', :query => params)
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
    result += "To Register (and for more info): <a href='#{event.meeting_url}'>#{event.meeting_url}</a>.<br/>"
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
    
  Change posts.php create_post() to:
  public function create_post() {
    global $json_api;

    if (!$json_api->query->author) {
      $json_api->error("You must include 'author' var in your request.");
    }
    if (!$json_api->query->nonce) {
      $json_api->error("You must include a 'nonce' value to create posts. Use the `get_nonce` Core API method.");
    }
    $nonce_id = $json_api->get_nonce_id('posts', 'create_post');
    if (!wp_verify_nonce($json_api->query->nonce, $nonce_id)) {
      $json_api->error("Your 'nonce' value was incorrect. Use the 'get_nonce' API method.");
    }

    if ($json_api->query->user_name && $json_api->query->user_password) {
      $user = wp_authenticate($json_api->query->user_name, $json_api->query->user_password);
      if (is_wp_error($user)) {
        $json_api->error("Invalid username and/or password.", 'error', '401');
        remove_action('wp_login_failed', $json_api->query->user_name);
      }
      if (!user_can($user->ID,'edit_posts')) {
        $json_api->error("You need to login with a user capable of creating posts.");
      }
    } else {
      if (!current_user_can('edit_posts')) {
        $json_api->error("You need to login with a user capable of creating posts.");
      }
    }

    nocache_headers();
    $post = new JSON_API_Post();
    $post->set_author_value($json_api->query->author);
    $id = $post->create($_REQUEST);
    if (empty($id)) {
      $json_api->error("Could not create post.");
    }
    return array(
      'post' => $post
    );
  }
  
  And posts.php update_post() to:
  public function update_post() {
    global $json_api;
    $post = $json_api->introspector->get_current_post();
    if (empty($post)) {
      $json_api->error("Post not found.");
    }
    if (!$json_api->query->nonce) {
      $json_api->error("You must include a 'nonce' value to update posts. Use the `get_nonce` Core API method.");
    }
    $nonce_id = $json_api->get_nonce_id('posts', 'update_post');
    if (!wp_verify_nonce($json_api->query->nonce, $nonce_id)) {
      $json_api->error("Your 'nonce' value was incorrect. Use the 'get_nonce' API method.");
    }
    if ($json_api->query->user_name && $json_api->query->user_password) {
      $user = wp_authenticate($json_api->query->user_name, $json_api->query->user_password);
      if (is_wp_error($user)) {
        $json_api->error("Invalid username and/or password.", 'error', '401');
        remove_action('wp_login_failed', $json_api->query->user_name);
      }
      if (!user_can($user->ID,'edit_posts')) {
        $json_api->error("You need to login with a user capable of creating posts.");
      }
    } else {
      if (!current_user_can('edit_posts')) {
        $json_api->error("You need to login with a user capable of creating posts.");
      }
    }

    nocache_headers();
    $post = new JSON_API_Post($post);
    $post->update($_REQUEST);
    return array(
      'post' => $post
    );
  }
=end