class CommunityMailer < EventMailer
  def recipient
    Rails.configuration.community_email
  end
end