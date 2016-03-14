class CreateApplications < ActiveRecord::Migration

  def change
    create_table :applications do |t|
      t.string :name
      t.text :description
      t.string :url
      t.string :source_url
      t.string :creator_name

      t.timestamps
    end
  end

end
