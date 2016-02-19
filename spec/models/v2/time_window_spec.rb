require 'rails_helper'

describe V2::TimeWindow do
  describe '#slots' do
    subject do
      described_class.new(
        date:  '06/12/2016',
        start_time: '09:30',
        end_time:   '10:30',
        slot_length: '30 mins'
      ).slots
    end

    it 'returns 2 time slots' do
      expect(subject.count).to eql 2
    end

    it 'returns a time slot from 09:30 to 10:00' do
      expect(
        subject.find do |time_slot|
          time_slot.start_time == Time.zone.parse('12/06/2016 09:30') &&
          time_slot.end_time   == Time.zone.parse('12/06/2016 10:00')
        end
      ).to_not be_nil
    end

    it 'returns a time slot from 10:00 to 10:30' do
      expect(
        subject.find do |time_slot|
          time_slot.start_time == Time.zone.parse('12/06/2016 10:00') &&
          time_slot.end_time   == Time.zone.parse('12/06/2016 10:30')
        end
      ).to_not be_nil
    end
  end
end
