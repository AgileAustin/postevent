class ChangeOauth < ActiveRecord::Migration
  def change
  	remove_column :users, :linkedin_token
  	remove_column :users, :linkedin_token_expiration

    create_table :systems do |t|
      t.string :meetup_access_token
      t.string :meetup_refresh_token
    end
   
    execute <<-SQL
      INSERT INTO systems (meetup_access_token, meetup_refresh_token) VALUES (NULL, NULL)
    SQL
  end
end
