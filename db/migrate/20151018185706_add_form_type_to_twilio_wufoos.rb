class AddFormTypeToTwilioWufoos < ActiveRecord::Migration

  def change
    add_column :twilio_wufoos, :form_type, :string
  end

end
