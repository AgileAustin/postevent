class User < ActiveRecord::Base
  has_many :events
  attr_accessible :email, :password, :password_confirmation
  has_secure_password
  validates :email, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :password, :length => {:maximum => 255}
  validates_presence_of :password, :on => :create
end
