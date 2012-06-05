class Location < ActiveRecord::Base
  has_many :events
  attr_accessible :name, :address, :directions
  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :address, :presence => true, :length => {:maximum => 255}
  validates :directions, :length => {:maximum => 65536}
end
