require 'rails_helper'

describe V2::TimeSlot do
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }

  # time_slot = TimeSlot.new(start_time: ..., end_time: ...)
  # expect(time_slot).to_not be_valid

  # existing slot that matches the start and end times perfectly

  # slots that are within, or intersect the start and end time range
end
