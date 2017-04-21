class Addreferredbytoperson < ActiveRecord::Migration
  def change
    add_column :people, :referred_by, :string
  end
end
