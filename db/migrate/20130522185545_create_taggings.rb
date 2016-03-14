class CreateTaggings < ActiveRecord::Migration

  def change
    create_table :taggings do |t|
      t.string :taggable_type
      t.integer :taggable_id
      t.integer :created_by

      t.timestamps
    end
  end

end
