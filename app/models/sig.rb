class Sig < ActiveRecord::Base
  has_many :events
  attr_accessible :email, :google_group, :name
  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :google_group, :length => {:maximum => 255}
  validates :name, :length => {:maximum => 255}
  
  def wordpress_category
    name.downcase.gsub(/ /,'-')
  end
end