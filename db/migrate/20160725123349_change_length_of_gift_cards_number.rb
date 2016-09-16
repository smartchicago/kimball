class ChangeLengthOfGiftCardsNumber < ActiveRecord::Migration
  def change
  	change_column :gift_cards, :gift_card_number, :integer, :limit => 8
  end
end
