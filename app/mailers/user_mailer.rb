class UserMailer < ActionMailer::Base
  default :from => Rails.configuration.email_contact
  
  def registration_confirmation(user, password)
    @user = user
    @password = password
    mail(:to => user.email, :subject => "Posting Events")  
  end  
end