class AddMeetupIds < ActiveRecord::Migration
  def change
    add_column :locations, :meetup_id, :string
    add_column :events, :meetup_id, :string
  end
end