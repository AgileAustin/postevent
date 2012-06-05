class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :title
      t.integer :sig_id
      t.text :description
      t.date :date
      t.time :start
      t.time :end
      t.integer :location_id
      t.integer :capacity
      t.string :food_sponsor
      t.string :speaker
      t.string :speaker_bio
      t.string :special_instructions

      t.timestamps
    end
  end
end
