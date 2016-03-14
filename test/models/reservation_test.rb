# == Schema Information
#
# Table name: reservations
#
#  id           :integer          not null, primary key
#  person_id    :integer
#  event_id     :integer
#  confirmed_at :datetime
#  created_by   :integer
#  attended_at  :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  updated_by   :integer
#

require 'test_helper'

class ReservationTest < ActiveSupport::TestCase

  test 'should associate person with event' do
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
