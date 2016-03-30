class CreateMailchimpUpdates < ActiveRecord::Migration
  def change
    create_table :mailchimp_updates do |t|
      t.text :raw_content
      t.string :email
      t.string :update_type
      t.string :reason
      t.datetime :fired_at

      t.timestamps null: false
    end
  end
end
