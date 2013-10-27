class AddLinkedinTokenInfo < ActiveRecord::Migration
  def change
    add_column :users, :linkedin_token, :string
    add_column :users, :linkedin_token_expiration, :timestamp
  end
end