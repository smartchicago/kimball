class AddNeighborhoodToPerson < ActiveRecord::Migration
  def change
    add_column :people, :neighborhood, :string
  end
end
