class AddEndMessageToTwilioWufoos < ActiveRecord::Migration

  def change
    add_column :twilio_wufoos, :end_message, :string
  end

end
