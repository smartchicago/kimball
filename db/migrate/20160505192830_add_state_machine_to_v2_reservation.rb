class AddStateMachineToV2Reservation < ActiveRecord::Migration
  def change
    add_column :v2_reservations, :aasm_state, :string
  end
end
