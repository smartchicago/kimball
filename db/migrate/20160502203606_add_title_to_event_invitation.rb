class AddTitleToEventInvitation < ActiveRecord::Migration
  def change
    add_column :v2_event_invitations, :title, :string
  end
end
