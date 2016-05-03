require 'faker'

FactoryGirl.define do
  factory :event_invitation, class: V2::EventInvitation do
    title 'event title'
    description 'Lorem ipsum for now'
    slot_length 15
    buffer 0
    event
    user

    before(:create) do |event_invitation|
      invitees = FactoryGirl.create_list(:person, 3)
      event_invitation.invitees << invitees
      event_invitation.email_addresses = invitees.collect(&:email_address).join(',')

      start_time = DateTime.now.in_time_zone + 1.day
      # three slots, one for each person
      end_time = start_time + (15 * 3).minutes

      event_invitation.date = start_time.strftime('%m/%d/%Y')
      event_invitation.start_time = start_time.strftime('%H:%M')
      event_invitation.end_time = end_time.strftime('%H:%M')
    end
  end
end
