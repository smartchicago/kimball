require 'faker'

FactoryGirl.define do
  factory :event_invitation, class: V2::EventInvitation do
    description 'Lorem ipsum for now'
    slot_length 15

    event

    before(:create) do |event_invitation|
      invitees = FactoryGirl.create_list(:person, 3)

      event_invitation.invitees << invitees
      event_invitation.email_addresses = invitees.collect(&:email_address).join(',')

      start_time = Faker::Time.forward(2)
      end_time = start_time + 15.minutes

      event_invitation.date = start_time.strftime('%m/%d/%Y')
      event_invitation.start_time = start_time.strftime('%H:%M')
      event_invitation.end_time = end_time.strftime('%H:%M')
    end
  end
end
