class Location < ActiveRecord::Base
  has_many :events
  attr_accessible :name, :address, :city, :state, :postal_code, :directions
  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :address, :presence => true, :length => {:maximum => 255}
  validates :city, :presence => true, :length => {:maximum => 255}
  validates :state, :presence => true, :length => {:maximum => 2}
  validates :postal_code, :length => {:maximum => 255}
  validates :directions, :length => {:maximum => 65536}
end