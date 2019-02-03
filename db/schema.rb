# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20190116030342) do

  create_table "associations", :force => true do |t|
    t.string   "user_id"
    t.string   "nonce"
    t.datetime "nonce_expiration_time"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.integer  "sig_id"
    t.text     "description"
    t.date     "date"
    t.time     "start"
    t.time     "end"
    t.integer  "location_id"
    t.integer  "capacity"
    t.string   "food_sponsor"
    t.string   "speaker"
    t.string   "speaker_bio"
    t.string   "special_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "eventbrite_id"
    t.string   "ticket_eventbrite_id"
    t.string   "google_id"
    t.string   "wordpress_id"
    t.string   "meetup_id"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.text     "directions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "eventbrite_id"
    t.string   "city"
    t.string   "state",         :limit => 2
    t.string   "postal_code"
    t.string   "address2"
    t.string   "meetup_id"
  end

  create_table "sigs", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "google_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "linkedin_token"
    t.datetime "linkedin_token_expiration"
    t.string   "slack_user_id"
  end

end
