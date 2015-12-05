class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :sig
  belongs_to :location
  attr_accessible :user_id, :date, :start, :end, :title, :sig_id, :location_id, :description, :capacity, :food_sponsor, :speaker, :speaker_bio, :special_instructions
  validates :date, :presence => true
  validates :start, :presence => true
  validates :end, :presence => true
  validates :title, :presence => true, :length => {:maximum => 255}
  validates :description, :presence => true, :length => {:maximum => 65536}
  validates :capacity, :presence => true
  validates :food_sponsor, :presence => true, :length => {:maximum => 255}
  validates :speaker, :length => {:maximum => 255}
  validates :speaker_bio, :length => {:maximum => 65536}
  validates :special_instructions, :length => {:maximum => 65536}
  validates :sig, :presence => true
  validates :location, :presence => true
  validate :validate_date
  
  def group_title
    sig.name + " - " + title
  end
  
  def meetup_url
    if Rails.configuration.meetup_group_urlname
      if meetup_id
        "http://www.meetup.com/" + Rails.configuration.meetup_group_urlname + "/events/" + meetup_id + "/"
      else
        "http://www.meetup.com/" + Rails.configuration.meetup_group_urlname + "/"
      end
    else
        "http://www.meetup.com/"
     end
  end
  
  def eventbrite_url
    "http://www.eventbrite.com/event/" + (eventbrite_id ? eventbrite_id : '')
  end
  
  def meeting_url
    if meetup_id || !eventbrite_id
      meetup_url
    else
      eventbrite_url
    end
  end
  
  def validate_date
    errors.add("Date", "must be in future.") unless date.future?
  end
end