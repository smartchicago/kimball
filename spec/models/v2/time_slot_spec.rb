require 'rails_helper'

describe V2::TimeSlot do
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }

  it 'does not save overlapping timeslots' do
    existing = FactoryGirl.create(:time_slot)
    time_slot = ::V2::TimeSlot.new(start_time: existing.start_time, end_time: existing.end_time)
    expect(time_slot).to_not be_valid

    time_slot = ::V2::TimeSlot.new(start_time: existing.start_time + 10.minutes, end_time: existing.end_time + 50.minutes)
    expect(time_slot).to_not be_valid
  end
end
