class ErrorMailer < ActionMailer::Base
  default :from => Rails.configuration.email_contact
  
  def errors(errors, type)
    @errors = errors
    mail(:to => Rails.configuration.email_contact, :subject => "Errors " + type)
  end  
end