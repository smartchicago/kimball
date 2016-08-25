# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  description    :text(65535)
#  starts_at      :datetime
#  ends_at        :datetime
#  location       :text(65535)
#  address        :text(65535)
#  capacity       :integer
#  application_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  created_by     :integer
#  updated_by     :integer
#

require 'faker'

FactoryGirl.define do
  factory :event, class: V2::Event do
    description 'Lorem ipsum for now'
    user

    before(:create) do |event|
      event.time_slots << FactoryGirl.build_list(:time_slot, 3).each { |t| t.event_id = event.id }
    end

    after(:create) do |event|
      FactoryGirl.create(:event_invitation, event: event)
    end

    trait :fully_booked do
      after(:create) do |event|
        event.time_slots.each do |slot|
          V2::Reservation.create(person: FactoryGirl.create(:person),
                                 time_slot: slot,
                                 event: event,
                                 event_invitation: event.event_invitation,
                                 user: event.user)
        end
      end
    end
  end
end
