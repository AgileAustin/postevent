class ManualMailer < EventMailer
  def recipient
    Rails.configuration.email_contact
  end
end