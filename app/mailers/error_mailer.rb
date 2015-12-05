class ErrorMailer < ActionMailer::Base
  default :from => Rails.configuration.email_contact
  
  def errors(errors, type)
    @errors = errors
    mail(:to => contact, :subject => "Errors " + type)
  end  
  
  def contact
    Rails.configuration.error_contact ? Rails.configuration.error_contact : Rails.configuration.email_contact
  end
end