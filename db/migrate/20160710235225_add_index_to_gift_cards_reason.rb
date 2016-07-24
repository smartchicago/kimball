class AddIndexToGiftCardsReason < ActiveRecord::Migration
  def change
    add_index :gift_cards, :reason, name: 'gift_reason_index'
  end
end
