class AddVerifiedToPeople < ActiveRecord::Migration
  def change
  	add_column :people, :verified, :boolean, default: false, null: false 
  end
end
