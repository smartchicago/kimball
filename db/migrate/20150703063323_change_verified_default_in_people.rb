class ChangeVerifiedDefaultInPeople < ActiveRecord::Migration
  def change
  	change_column :people, :verified, :text, { default: '' }
  end
end
