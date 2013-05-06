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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130502205047) do

  create_table "comments", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email_address"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.integer  "geography_id"
    t.integer  "primary_device_id"
    t.string   "primary_device_description"
    t.integer  "secondary_device_id"
    t.string   "secondary_device_description"
    t.integer  "primary_connection_id"
    t.string   "primary_connection_description"
    t.string   "phone_number"
    t.string   "participation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "signup_ip"
    t.datetime "signup_at"
    t.string   "voted"
    t.string   "called_311"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "invitation_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", force: true do |t|
    t.text     "raw_content"
    t.integer  "person_id"
    t.string   "ip_addr"
    t.string   "entry_id"
    t.text     "form_structure"
    t.text     "field_structure"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
