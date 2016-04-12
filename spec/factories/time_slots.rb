require 'faker'

FactoryGirl.define do
  factory :time_slot, class: V2::TimeSlot do
    sequence(:start_time) { |i| Faker::Time.forward(i.day, :morning) }
    end_time   { start_time + 30.minutes }

    trait :booked do
      reservation
    end
  end
end
