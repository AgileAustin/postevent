class Associations < ActiveRecord::Base
  attr_accessible :user_id, :nonce, :nonce_expiration_time
  validates :user_id, :presence => true
  validates :nonce, :presence => true, :uniqueness => true
  validates :nonce_expiration_time, :presence => true
end
