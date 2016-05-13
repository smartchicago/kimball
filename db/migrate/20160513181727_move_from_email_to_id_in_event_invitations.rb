class MoveFromEmailToIdInEventInvitations < ActiveRecord::Migration
  def change
    rename_column :v2_event_invitations, :email_addresses, :people_ids
  end
end
