class ChangeVerifiedTypeInPeople < ActiveRecord::Migration
  def change
  	change_column :people, :verified, :text
  end
end
