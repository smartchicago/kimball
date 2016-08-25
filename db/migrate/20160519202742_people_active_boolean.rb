class PeopleActiveBoolean < ActiveRecord::Migration
  def change
    add_column :people, :active, :boolean, default: true
    add_column :people, :deactivated_at, :datetime
    add_column :people, :deactivated_method, :string
  end
end
