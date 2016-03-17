require 'faker'

FactoryGirl.define do
  factory :reservation, class: V2::Reservation do
    person
    time_slot
  end
end
