class AddProxyidToGiftcards < ActiveRecord::Migration
  def change
    add_column :gift_cards, :proxy_id, :integer
  end
end
