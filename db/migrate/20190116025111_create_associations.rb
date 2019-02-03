class CreateAssociations < ActiveRecord::Migration
  def change
    create_table :associations do |t|
  		t.string 		:user_id
  		t.string		:nonce
  		t.timestamp		:nonce_expiration_time

  		t.timestamps
  	end
  end
end
