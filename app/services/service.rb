class Service
  def create(event, errors)
    begin
      create_event(event)
    rescue => e
      add_error(errors, e)
    end
  end
  
  def update(event, errors)
    begin
      update_event(event)
    rescue => e
      add_error(errors, e)
    end
  end
  
  def add_error(errors, e)
    errors << {:service => self.class.name, :error => e.message, :stack => e.backtrace}
  end
end