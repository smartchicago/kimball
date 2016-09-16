class ChangeGiftCardExpDateToString < ActiveRecord::Migration
  def change
  	change_column :gift_cards, :expiration_date, :string
  end
end
