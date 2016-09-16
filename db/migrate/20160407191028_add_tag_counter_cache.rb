class AddTagCounterCache < ActiveRecord::Migration
  def change
    add_column :tags, :taggings_count, :integer, :null => false, :default => 0
  end
end
