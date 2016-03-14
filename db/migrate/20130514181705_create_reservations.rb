class CreateReservations < ActiveRecord::Migration

  def change
    create_table :reservations do |t|
      t.integer :person_id
      t.integer :event_id
      t.datetime :confirmed_at
      t.integer :created_by
      t.datetime :attended_at

      t.timestamps
    end
  end

end
