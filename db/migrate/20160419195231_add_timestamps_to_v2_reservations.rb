class AddTimestampsToV2Reservations < ActiveRecord::Migration
  def change
    change_table(:v2_reservations) { |t| t.timestamps }
  end
end
