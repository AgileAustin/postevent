class Service
  def create(event, errors, user = nil)
    begin
      if user == nil
        create_event(event)
      else
        create_event(user, event)
      end
    rescue => e
      add_error(errors, e)
    end
  end
  
  def update(event, errors, user = nil)
    begin
      if user == nil
        update_event(event)
      else
        update_event(user, event)
      end
    rescue => e
      add_error(errors, e)
    end
  end
  
  def add_error(errors, e)
    errors << {:service => self.class.name, :error => e.message, :stack => e.backtrace}
  end
end