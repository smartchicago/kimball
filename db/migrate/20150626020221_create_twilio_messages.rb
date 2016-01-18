class CreateTwilioMessages < ActiveRecord::Migration

  def change
    create_table :twilio_messages do |t|
      t.string :message_sid
      t.datetime 'date_created'
      t.datetime 'date_updated'
      t.datetime 'date_sent'
      t.string   'account_sid'
      t.string   'from'
      t.string   'to'
      t.string   'body'
      t.string   'status'
      t.string   'error_code'
      t.string   'error_message'
      t.string   'direction'
      t.string   'from_city'
      t.string   'from_state'
      t.string   'from_zip'
      t.string   'wufoo_formid'
      t.integer  'conversation_count'
      t.string   'signup_verify'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.timestamps
    end
  end

end
