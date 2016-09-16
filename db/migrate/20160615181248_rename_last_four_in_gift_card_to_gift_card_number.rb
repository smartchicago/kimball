class RenameLastFourInGiftCardToGiftCardNumber < ActiveRecord::Migration
  def change
  	rename_column :gift_cards, :last_four, :gift_card_number
  end
end
