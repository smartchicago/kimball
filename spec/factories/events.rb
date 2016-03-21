require 'faker'

FactoryGirl.define do
  factory :event, class: V2::Event do
    description 'Lorem ipsum for now'

    before(:create) do |event|
      event.time_slots << FactoryGirl.build_list(:time_slot, 3)
    end

    trait :fully_booked do
      after(:create) do |event|
        event.time_slots.each { |slot| FactoryGirl.create(:reservation, time_slot: slot) }
      end
    end
  end
end
