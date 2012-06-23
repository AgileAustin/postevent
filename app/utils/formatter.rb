class Formatter
  def format_date(date)
    date.month.to_s + "/" + date.day.to_s + "/" + (date.year % 100).to_s
  end
  
  def format_time(time) # For some reason strftime isn't working here
    @meridian = 'am'
    @hour = time.hour
    if time.hour >= 12
      @meridian = 'pm'
    end
    if time.hour > 12
      @hour = time.hour - 12
    end
    @hour.to_s + ':' + (time.min < 10 ? '0' : '') + time.min.to_s + " " + @meridian
  end
end