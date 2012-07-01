# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Postevent::Application.initialize!

class LinkedIn::Client
  def post_to_group(group_id, post_data)
    path = "/groups/#{group_id}/posts"
    post(path, post_data.to_json, "Content-Type" => "application/json")
  end
end