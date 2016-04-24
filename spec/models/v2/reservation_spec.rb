# == Schema Information
#
# Table name: v2_reservations
#
#  id                  :integer          not null, primary key
#  time_slot_id        :integer
#  person_id           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#  event_id            :integer
#  event_invitation_id :integer
#

require 'rails_helper'

describe V2::Reservation do
  # it { is_expected.to validate_presence_of(:person) }
  # it { is_expected.to validate_presence_of(:user) }
  # it { is_expected.to validate_presence_of(:time_slot) }
  # it { is_expected.to validate_presence_of(:event) }
  # it { is_expected.to validate_presence_of(:event_invitation) }
  # it { is_expected.to validate_uniqueness_of(:time_slot_id) }
  subject { described_class }

  describe 'when different users, same person' do
    let(:event_invitation) { FactoryGirl.create(:event_invitation) }
    let(:person) { event_invitation.invitees.first }
    let(:event_invitation_2) { FactoryGirl.create(:event_invitation) }

    it 'should not alow a person to be double booked' do
      valid_args_1 = build_valid_args_from_event_invitation(event_invitation)
      event_invitation_2.invitees << person

      valid_args_2 = build_valid_args_from_event_invitation(event_invitation_2)
      valid_args_2[:person] = person

      reservation_1 = subject.new(valid_args_1)
      expect(reservation_1).to be_valid
      reservation_1.save
      reservation_2 = subject.new(valid_args_2)
      expect(reservation_2).not_to be_valid
    end
  end

  describe 'same user, different people' do
    let(:event_invitation) { FactoryGirl.create(:event_invitation) }
    let(:event_invitation_2) { FactoryGirl.create(:event_invitation, user: event_invitation.user) }

    it 'should not allow a user to be double booked' do
      valid_args_1 = build_valid_args_from_event_invitation(event_invitation)
      valid_args_2 = build_valid_args_from_event_invitation(event_invitation_2)

      reservation_1 = subject.new(valid_args_1)
      expect(reservation_1).to be_valid
      reservation_1.save
      reservation_2 = subject.new(valid_args_2)
      expect(reservation_2).not_to be_valid
    end
  end
end

def build_valid_args_from_event_invitation(event_invitation)
  {
    event_invitation: event_invitation,
    user: event_invitation.user,
    person: event_invitation.invitees.first,
    event: event_invitation.event,
    time_slot: event_invitation.event.time_slots.first
  }
end
