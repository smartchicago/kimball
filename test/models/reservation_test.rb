require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  test "should associate person with event" do
    person = people(:two)
    event = events(:two)
    assert !person.events.include?(event)

    assert_difference 'Reservation.count' do
      Reservation.create(person: person, event: event)
    end
    
    person.reload
    assert person.events.include?(event)
  end
end
