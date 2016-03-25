class CreateInvitationInviteesJoinTable < ActiveRecord::Migration
  def change
    create_table :invitation_invitees_join_table do |t|
      t.references :person
      t.references :event_invitation

      t.timestamps null: false
    end
  end
end
