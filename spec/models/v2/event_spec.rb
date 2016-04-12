# == Schema Information
#
# Table name: v2_events
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  description :string(255)
#

require 'rails_helper'

describe V2::Event do
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:time_slots) }

  describe '#available_time_slots' do
    subject { FactoryGirl.create(:event) }

    context 'when a time slot is already reserved but others are available' do
      let(:booked_slot) { FactoryGirl.create(:time_slot, :booked) }

      it 'returns only the slots that were not booked' do
        subject.time_slots.each do |slot|
          expect(subject.available_time_slots).to include(slot)
        end

        subject.time_slots << booked_slot

        expect(subject.available_time_slots).to_not include(booked_slot)
      end
    end

    context 'when time window is all booked' do
      subject { FactoryGirl.create(:event, :fully_booked) }

      it 'is empty' do
        expect(subject.available_time_slots).to be_empty
      end
    end
  end
end
