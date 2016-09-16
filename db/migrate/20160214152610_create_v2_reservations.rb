class CreateV2Reservations < ActiveRecord::Migration
  def change
    create_table :v2_reservations do |t|
      t.integer  :time_slot_id
      t.integer  :person_id
    end
  end
end
