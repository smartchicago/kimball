class CreateGiftCards < ActiveRecord::Migration
  def change
    create_table :gift_cards do |t|
      t.integer :last_four
      t.date :expiration_date
      t.integer :person_id
      t.string :notes
      t.integer :created_by
      t.integer :reason
      t.monetize :amount
      t.references :giftable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
