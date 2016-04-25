class AddUserIdToEventInvitations < ActiveRecord::Migration
  def change
    add_column :v2_event_invitations, :user_id, :integer
  end
end
