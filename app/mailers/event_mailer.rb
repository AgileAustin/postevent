class EventMailer < ActionMailer::Base
  default :from => Rails.configuration.email_contact
  
  def event_submitted(event, options = {})
    formatter = Formatter.new
    @event = event
    @date = formatter.format_date(@event.date)
    @start = formatter.format_time(@event.start)
    @end = formatter.format_time(@event.end)
    if recipient
      mail(:to => recipient, :subject => subject(event, options))
    end
  end  
  
  def recipient
    nil
  end
  
  def subject(event, options)
    prefix = options[:prefix] ? options[:prefix] : ''
    prefix + event.sig.name + " - " + event.title
  end
end