class CreatePeople < ActiveRecord::Migration

  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :postal_code
      t.integer :geography_id
      t.integer :primary_device_id
      t.string :primary_device_description
      t.integer :secondary_device_id
      t.string :secondary_device_description
      t.integer :primary_connection_id
      t.string :primary_connection_description
      t.string :phone_number
      t.string :participation_type

      t.timestamps
    end
  end

end
