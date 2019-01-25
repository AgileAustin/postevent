require 'json'
require 'securerandom'

module Slack
	class Commands < Grape::API
		resource :get_post_link do
            params do
                requires :user_id, type: String
            end
            post do
                slack_user_id = params[:user_id]
                association_nonce = SecureRandom.hex()
                association = Associations.new(:user_id => slack_user_id,
                                               :nonce => association_nonce,
                                               :nonce_expiration_time => 5.minutes.from_now)
                association.save
                # Check if user is already associated
                user = User.find_by_slack_user_id(slack_user_id)
                link = "https://#{request.host_with_port}/session/connect/slack?nonce=#{association.nonce}"
                if not user
                    attachments = [
                        {
                            fallback: "Click #{link}",
                            actions: [
                                {
                                    type: "button",
                                    text: "Link slack user to PostEvent",
                                    url: link
                                }
                            ]
                        }
                    ]
                    text = "You have not connected your slack account to your PostEvent login.\nClick on the button below to link the user. \nThis will logout the current post event user in the browser session."
                else
                    attachments = [
                        {
                            fallback: "Click #{link}",
                            actions: [
                                {
                                    type: "button",
                                    text: "Post Event",
                                    url: link
                                }
                            ]
                        }
                    ]
                    text = "Click on the button below to post an event. \nThis will logout the current post event user in the browser session."
                end

                {
                    text: text,
                    attachments: attachments
                }
            end
		end
	end
end
