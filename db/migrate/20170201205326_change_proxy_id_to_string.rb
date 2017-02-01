class ChangeProxyIdToString < ActiveRecord::Migration
  def change
    change_column :gift_cards, :proxy_id, :string
  end
end
