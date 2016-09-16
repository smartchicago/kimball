# == Schema Information
#
# Table name: v2_time_slots
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  start_time :datetime
#  end_time   :datetime
#

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

  it 'does allow overlapping for different events' do
    event_1 = FactoryGirl.create(:time_slot, event_id: 1)
    time_slot = ::V2::TimeSlot.new(start_time: event_1.start_time, end_time: event_1.end_time, event_id: 2)
    expect(time_slot).to be_valid
  end
end
