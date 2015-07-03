class RemoveVerifiedInPeople < ActiveRecord::Migration
  def change
  	remove_column :people, :verified
  end
end
