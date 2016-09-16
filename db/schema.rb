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

ActiveRecord::Schema.define(version: 20160816094658) do

  create_table "applications", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description",  limit: 65535
    t.string   "url",          limit: 255
    t.string   "source_url",   limit: 255
    t.string   "creator_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id",   limit: 4
    t.integer  "created_by",   limit: 4
    t.integer  "updated_by",   limit: 4
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content",          limit: 65535
    t.integer  "user_id",          limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "commentable_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",       limit: 4
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               limit: 4,     default: 0, null: false
    t.integer  "attempts",               limit: 4,     default: 0, null: false
    t.text     "handler",                limit: 65535,             null: false
    t.text     "last_error",             limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",              limit: 255
    t.string   "queue",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delayed_reference_id",   limit: 4
    t.string   "delayed_reference_type", limit: 255
  end

  add_index "delayed_jobs", ["delayed_reference_type"], name: "delayed_jobs_delayed_reference_type"
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"
  add_index "delayed_jobs", ["queue"], name: "delayed_jobs_queue"

  create_table "events", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "location",       limit: 65535
    t.text     "address",        limit: 65535
    t.integer  "capacity",       limit: 4
    t.integer  "application_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",     limit: 4
    t.integer  "updated_by",     limit: 4
  end

  create_table "gift_cards", force: :cascade do |t|
    t.string   "gift_card_number", limit: 255
    t.string   "expiration_date",  limit: 255
    t.integer  "person_id",        limit: 4
    t.string   "notes",            limit: 255
    t.integer  "created_by",       limit: 4
    t.integer  "reason",           limit: 4
    t.integer  "amount_cents",     limit: 4,   default: 0,     null: false
    t.string   "amount_currency",  limit: 255, default: "USD", null: false
    t.integer  "giftable_id",      limit: 4
    t.string   "giftable_type",    limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "batch_id",         limit: 255
    t.integer  "proxy_id",         limit: 4
  end

  add_index "gift_cards", ["giftable_type", "giftable_id"], name: "index_gift_cards_on_giftable_type_and_giftable_id"
  add_index "gift_cards", ["reason"], name: "gift_reason_index"

  create_table "invitation_invitees_join_table", force: :cascade do |t|
    t.integer  "person_id",           limit: 4
    t.integer  "event_invitation_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "mailchimp_exports", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "body",       limit: 65535
    t.integer  "created_by", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailchimp_updates", force: :cascade do |t|
    t.text     "raw_content", limit: 65535
    t.string   "email",       limit: 255
    t.string   "update_type", limit: 255
    t.string   "reason",      limit: 255
    t.datetime "fired_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name",                       limit: 255
    t.string   "last_name",                        limit: 255
    t.string   "email_address",                    limit: 255
    t.string   "address_1",                        limit: 255
    t.string   "address_2",                        limit: 255
    t.string   "city",                             limit: 255
    t.string   "state",                            limit: 255
    t.string   "postal_code",                      limit: 255
    t.integer  "geography_id",                     limit: 4
    t.integer  "primary_device_id",                limit: 4
    t.string   "primary_device_description",       limit: 255
    t.integer  "secondary_device_id",              limit: 4
    t.string   "secondary_device_description",     limit: 255
    t.integer  "primary_connection_id",            limit: 4
    t.string   "primary_connection_description",   limit: 255
    t.string   "phone_number",                     limit: 255
    t.string   "participation_type",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "signup_ip",                        limit: 255
    t.datetime "signup_at"
    t.string   "voted",                            limit: 255
    t.string   "called_311",                       limit: 255
    t.integer  "secondary_connection_id",          limit: 4
    t.string   "secondary_connection_description", limit: 255
    t.string   "verified",                         limit: 255
    t.string   "preferred_contact_method",         limit: 255
    t.string   "token",                            limit: 255
    t.boolean  "active",                                       default: true
    t.datetime "deactivated_at"
    t.string   "deactivated_method",               limit: 255
    t.string   "neighborhood",                     limit: 255
    t.integer  "tag_count_cache",                  limit: 4,   default: 0
  end

  create_table "programs", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",  limit: 4
    t.integer  "updated_by",  limit: 4
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "person_id",    limit: 4
    t.integer  "event_id",     limit: 4
    t.datetime "confirmed_at"
    t.integer  "created_by",   limit: 4
    t.datetime "attended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updated_by",   limit: 4
  end

  create_table "submissions", force: :cascade do |t|
    t.text     "raw_content",     limit: 65535
    t.integer  "person_id",       limit: 4
    t.string   "ip_addr",         limit: 255
    t.string   "entry_id",        limit: 255
    t.text     "form_structure",  limit: 65535
    t.text     "field_structure", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "form_id",         limit: 255
    t.integer  "form_type",       limit: 4,     default: 0
  end

  create_table "taggings", force: :cascade do |t|
    t.string   "taggable_type", limit: 255
    t.integer  "taggable_id",   limit: 4
    t.integer  "created_by",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_id",        limit: 4
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "created_by",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taggings_count", limit: 4,   default: 0, null: false
  end

  create_table "twilio_messages", force: :cascade do |t|
    t.string   "message_sid",        limit: 255
    t.datetime "date_created"
    t.datetime "date_updated"
    t.datetime "date_sent"
    t.string   "account_sid",        limit: 255
    t.string   "from",               limit: 255
    t.string   "to",                 limit: 255
    t.string   "body",               limit: 255
    t.string   "status",             limit: 255
    t.string   "error_code",         limit: 255
    t.string   "error_message",      limit: 255
    t.string   "direction",          limit: 255
    t.string   "from_city",          limit: 255
    t.string   "from_state",         limit: 255
    t.string   "from_zip",           limit: 255
    t.string   "wufoo_formid",       limit: 255
    t.integer  "conversation_count", limit: 4
    t.string   "signup_verify",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twilio_wufoos", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "wufoo_formid",   limit: 255
    t.string   "twilio_keyword", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",                     default: false, null: false
    t.string   "end_message",    limit: 255
    t.string   "form_type",      limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "password_salt",          limit: 255
    t.string   "invitation_token",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",                           default: false, null: false
    t.string   "name",                   limit: 255
    t.string   "token",                  limit: 255
    t.string   "phone_number",           limit: 255
  end

  create_table "v2_event_invitations", force: :cascade do |t|
    t.integer  "v2_event_id", limit: 4
    t.string   "people_ids",  limit: 255
    t.string   "description", limit: 255
    t.string   "slot_length", limit: 255
    t.string   "date",        limit: 255
    t.string   "start_time",  limit: 255
    t.string   "end_time",    limit: 255
    t.integer  "buffer",      limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     limit: 4
    t.string   "title",       limit: 255
  end

  create_table "v2_events", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "v2_reservations", force: :cascade do |t|
    t.integer  "time_slot_id",        limit: 4
    t.integer  "person_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",             limit: 4
    t.integer  "event_id",            limit: 4
    t.integer  "event_invitation_id", limit: 4
    t.string   "aasm_state",          limit: 255
  end

  create_table "v2_time_slots", force: :cascade do |t|
    t.integer  "event_id",   limit: 4
    t.datetime "start_time"
    t.datetime "end_time"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 191,        null: false
    t.integer  "item_id",        limit: 4,          null: false
    t.string   "event",          limit: 255,        null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.text     "object_changes", limit: 4294967295
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
