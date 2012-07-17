class AddWordpressIds < ActiveRecord::Migration
  def change
    add_column :events, :wordpress_id, :string
  end
end