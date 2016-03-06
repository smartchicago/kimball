class AddStatusToTwilioWufoos < ActiveRecord::Migration

  def change
    add_column :twilio_wufoos, :status, :boolean, null: false, default: false
  end

end
