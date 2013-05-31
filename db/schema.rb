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

ActiveRecord::Schema.define(version: 20130530234651) do

  create_table "applications", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.string   "source_url"
    t.string   "creator_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "comments", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
  end

  create_table "events", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "location"
    t.text     "address"
    t.integer  "capacity"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "mailchimp_exports", force: true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "created_by"
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
    t.integer  "secondary_connection_id"
    t.string   "secondary_connection_description"
  end

  create_table "programs", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "reservations", force: true do |t|
    t.integer  "person_id"
    t.integer  "event_id"
    t.datetime "confirmed_at"
    t.integer  "created_by"
    t.datetime "attended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updated_by"
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

  create_table "taggings", force: true do |t|
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_id"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
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
    t.boolean  "approved",               default: false, null: false
  end

end
