class AddTicketFields < ActiveRecord::Migration
  def change
    add_column :events, :ticket_eventbrite_id, :string
  end
end