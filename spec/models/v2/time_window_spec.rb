require 'rails_helper'

describe V2::TimeWindow do
  describe '#slots' do
    subject do
      described_class.new(
        date:  '06/12/2016',
        start_time: '09:30',
        end_time:   '10:30',
        slot_length: '30 mins',
        event_id: 1
      )
    end

    context 'no buffer' do
      it 'returns 2 time slots' do
        expect(subject.slots.count).to eql 2
      end

      it 'assigns an event_id' do
        expect(subject.slots.first.event_id).to eql 1
      end

      it 'returns a time slot from 09:30 to 10:00' do
        expect(
          subject.slots.find do |time_slot|
            time_slot.start_time == Time.zone.parse('12/06/2016 09:30') &&
            time_slot.end_time   == Time.zone.parse('12/06/2016 10:00')
          end
        ).to_not be_nil
      end

      it 'returns a time slot from 10:00 to 10:30' do
        expect(
          subject.slots.find do |time_slot|
            time_slot.start_time == Time.zone.parse('12/06/2016 10:00') &&
            time_slot.end_time   == Time.zone.parse('12/06/2016 10:30')
          end
        ).to_not be_nil
      end
    end
    context 'with buffer' do
      subject do
        V2::TimeWindow.new(
          date:  '06/12/2016',
          start_time: '09:30',
          end_time:   '11:30',
          slot_length: '30 mins',
          event_id: 1,
          buffer: 30
        )
      end

      it 'returns 2 time slots' do
        expect(subject.slots.count).to eql 2
      end

      it 'should have 30 minutes between slots' do
        buffer = (subject.slots[1].start_time - subject.slots[0].end_time)
        expect(buffer.to_i).to eql 1800
      end
    end
  end
end
