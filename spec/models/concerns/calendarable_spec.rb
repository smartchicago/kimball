require 'rails_helper'

describe Calendarable do
  context 'reservation calendar' do
    let(:event_invitation) { FactoryGirl.create(:event_invitation) }
    let(:person) { event_invitation.invitees.sample }
    let(:time_slot) { event_invitation.event.time_slots.sample }
    let(:reservation) { V2::Reservation.create(person: person, time_slot: time_slot) }

    it 'can generate an ical event' do
      expect(reservation).to respond_to(:to_ics)
      expect(reservation.to_ics.description).to eq(reservation.description)
    end

    it 'has  an alarm' do
      ics = reservation.to_ics
      expect(ics.alarms.length).to eq(1)
    end
  end

  context 'event_invitation' do
    let(:ei) { FactoryGirl.create(:event_invitation) }

    it 'can generate an ical event' do
      expect(ei).to respond_to(:to_ics)
      expect(ei.to_ics.description).to eq(ei.description)
    end

    it 'should not have an alarm' do
      expect(ei.to_ics.alarms.length).to eq(0)
    end
  end
end
