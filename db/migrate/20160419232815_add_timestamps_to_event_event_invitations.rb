class AddTimestampsToEventEventInvitations < ActiveRecord::Migration
  def change
    change_table(:v2_event_invitations) { |t| t.timestamps }
    change_table(:v2_events) { |t| t.timestamps }
  end
end
