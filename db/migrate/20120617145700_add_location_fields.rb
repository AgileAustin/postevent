class AddLocationFields < ActiveRecord::Migration
  def change
    add_column :locations, :city, :string
    add_column :locations, :state, :string, :limit => 2
    add_column :locations, :postal_code, :string
  end
end