class AddEventbriteIds < ActiveRecord::Migration
  def change
    add_column :locations, :eventbrite_id, :string
    add_column :events, :eventbrite_id, :string
  end
end