class ChangeGiftCardNumberToString < ActiveRecord::Migration
  def change
  	change_column :gift_cards, :gift_card_number, :string
  end
end
