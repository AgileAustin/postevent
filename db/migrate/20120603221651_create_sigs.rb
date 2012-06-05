class CreateSigs < ActiveRecord::Migration
  def change
    create_table :sigs do |t|
      t.string :name
      t.string :email
      t.string :google_group

      t.timestamps
    end
  end
end
