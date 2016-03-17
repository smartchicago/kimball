require 'faker'

FactoryGirl.define do
  factory :event, class: V2::Event do
    description 'Lorem ipsum for now'

    before(:create) do |event|
      3.times { event.time_slots << FactoryGirl.create(:time_slot) }
    end

    trait :fully_booked do
      after(:create) do |event|
        event.time_slots.each { |slot| FactoryGirl.create(:reservation, time_slot: slot) }
      end
    end
  end
end
