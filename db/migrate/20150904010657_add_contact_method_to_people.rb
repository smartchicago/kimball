class AddContactMethodToPeople < ActiveRecord::Migration

  def change
    add_column :people, :preferred_contact_method, :string
  end

end
