class AddTagCounterCacheToPerson < ActiveRecord::Migration
  def change
    add_column :people, :tag_count_cache, :integer, default: 0
  end
end
