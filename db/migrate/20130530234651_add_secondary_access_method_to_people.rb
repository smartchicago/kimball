class AddSecondaryAccessMethodToPeople < ActiveRecord::Migration

  def change
    add_column :people, :secondary_connection_id, :integer
    add_column :people, :secondary_connection_description, :string
  end

end
