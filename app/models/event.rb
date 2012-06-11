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
end