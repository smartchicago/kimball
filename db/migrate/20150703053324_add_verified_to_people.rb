class AddVerifiedToPeople < ActiveRecord::Migration
  def change
  	add_column :people, :verified, :text
  end
end
