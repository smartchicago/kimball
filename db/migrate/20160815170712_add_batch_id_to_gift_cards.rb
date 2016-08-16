class AddBatchIdToGiftCards < ActiveRecord::Migration
  def change
    add_column :gift_cards, :batch_id, :string
  end
end
