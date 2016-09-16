class HydrateV2Reservations < ActiveRecord::Migration
  def change
    add_column :v2_reservations, :user_id, :integer
    add_column :v2_reservations, :event_id, :integer
    add_column :v2_reservations, :event_invitation_id, :integer
  end
end
