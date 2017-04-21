class Addlowincometoperson < ActiveRecord::Migration
  def change
    add_column :people, :low_income, :boolean, null: true
  end
end
