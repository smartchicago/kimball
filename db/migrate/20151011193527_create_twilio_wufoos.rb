class CreateTwilioWufoos < ActiveRecord::Migration

  def change
    create_table :twilio_wufoos do |t|
      t.string :name
      t.string :wufoo_formid
      t.string :twilio_keyword

      t.timestamps
    end
  end

end
