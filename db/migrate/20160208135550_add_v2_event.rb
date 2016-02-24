class AddV2Event < ActiveRecord::Migration
  def change
    create_table :v2_events do |t|
      t.integer :user_id    
      t.string  :description
    end
  end
end
