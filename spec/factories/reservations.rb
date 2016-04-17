# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  person_id    :integer
#  time_slot_id :integer
#

require 'faker'

FactoryGirl.define do
  factory :reservation, class: V2::Reservation do
    person FactoryGirl.create(:person)

    before(:create) do |reservation|
      # make a time_slot
      reservation.time_slot = FactoryGirl.create(:time_slot)
    end
  end
end
