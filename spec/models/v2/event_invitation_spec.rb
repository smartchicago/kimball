# == Schema Information
#
# Table name: v2_event_invitations
#
#  id              :integer          not null, primary key
#  v2_event_id     :integer
#  email_addresses :string(255)
#  description     :string(255)
#  slot_length     :string(255)
#  date            :string(255)
#  start_time      :string(255)
#  end_time        :string(255)
#  buffer          :integer          default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer
#

require 'rails_helper'

describe V2::EventInvitation do
  it { is_expected.to validate_presence_of(:email_addresses) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:slot_length) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }

  describe '#save' do
    let(:people) { FactoryGirl.create_list(:person, 2) }
    let(:user) { FactoryGirl.create(:user) }
    let(:valid_args) do
      {
        email_addresses: people.map(&:email_address).join(','),
        description: 'lorem',
        slot_length: '45 mins',
        date: '03/20/2016',
        start_time: '15:00',
        end_time: '16:30',
        title: 'title',
        user_id: user.id
      }
    end

    describe 'when valid' do
      subject { described_class.new(valid_args) }

      it 'creates a new event' do
        expect { subject.save }.to change { V2::Event.count }.from(0).to(1)
      end

      it 'creates new time slots' do
        expect { subject.save }.to change { V2::TimeSlot.count }.from(0).to(2)
      end

      it 'finds the invitees and associates the to the event' do
        subject.save
        expect(subject.invitees.collect(&:id).sort).to eql people.collect(&:id).sort
      end

      it 'associates event to its creator' do
        subject.save
        expect(subject.event.user_id).to eq(user.id)
      end
    end

    describe 'when unregistered email addresses are present' do
      subject { described_class.new(valid_args.merge(email_addresses: 'bogus@email.com')) }

      it 'validates email addresses belong to registered people' do
        subject.save
        expect(subject.errors.messages[:email_addresses]).to eql ['One or more of the email addresses are not registered']
      end
    end

    describe 'with missing data' do
      it 'returns false' do
        expect(subject.save).to eql false
      end
    end
  end
end
