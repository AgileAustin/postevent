class User < ActiveRecord::Base
  has_many :events
  attr_accessible :email, :password, :password_confirmation, :linkedin_token, :linkedin_token_expiration, :slack_user_id
  has_secure_password
  validates :email, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :password, :length => {:maximum => 255}
  validates_presence_of :password, :on => :create

  def authorized_for_linkedin
    linkedin_token_expiration != nil && linkedin_token_expiration > DateTime.now
  end
end
