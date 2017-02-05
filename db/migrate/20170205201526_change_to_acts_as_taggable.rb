class ChangeToActsAsTaggable < ActiveRecord::Migration
  def change
    rename_table :tags, :old_tags
    rename_table :taggings, :old_taggings
  end
end
