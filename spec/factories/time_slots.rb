require 'faker'

FactoryGirl.define do
  factory :time_slot, class: V2::TimeSlot do
    sequence(:start_time) { |i| Time.current + (i*30).minutes }
    end_time   { start_time + 30.minutes }
    trait :booked do
      reservation
    end
  end
end
