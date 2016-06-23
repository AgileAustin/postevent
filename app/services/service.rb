class Service
  def create(event, errors, user = nil, announce=nil)
    begin
      if user == nil
        if announce == nil
          create_event(event)
        else
          create_event(event, announce)
        end
      else
        create_event(user, event)
      end
    rescue => e
      add_error(errors, e)
    end
  end
  
  def update(event, errors, user = nil, announce=nil)
    begin
      if user == nil
        if announce == nil
          update_event(event)
        else
          update_event(event, announce)
        end
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