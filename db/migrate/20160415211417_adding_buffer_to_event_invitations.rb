class AddingBufferToEventInvitations < ActiveRecord::Migration
  def change
    add_column :v2_event_invitations, :buffer, :integer, default: 0, null: false
  end
end
