require 'rails_helper'

describe V2::SmsReservationsController do
  include SmsSpec::Helpers

  let(:twilio_phone_number) { ENV['TWILIO_NUMBER'] }
  let(:user) { FactoryGirl.create(:user) }
  let!(:event_invitation) { FactoryGirl.create(:event_invitation) }

  let(:user_2) { FactoryGirl.create(:user) }
  let(:research_subject) { event_invitation.invitees.first }
  let(:research_subject_2) { event_invitation.invitees.last }
  let!(:event) {
    event_invitation.event.user_id = user.id
    event_invitation.event
  }

  before do
    clear_messages
  end

  describe 'POST #create' do
    describe 'research subject replies' do
      let(:message) { twiml_message(research_subject.phone_number, body, to: twilio_phone_number) }

      subject { post :create, message }

      context 'with existing time slot option' do
        let(:selected_number) { 'a' }
        let(:body) { "#{event.id}#{selected_number}" }
        let(:selected_time) { V2::Event.find(event.id).time_slots.first.to_weekday_and_time }

        it 'reserves the time slot for this person' do
          event_invitation.save!
          event.save
          subject
          expect(event.time_slots.first.reservation).to_not be_nil
        end

        it 'sends out a confirmation sms for this person' do
          subject
          open_last_text_message_for research_subject.phone_number
          expected = "An interview has been booked for #{selected_time}"
          expect(current_text_message.body).to eql expected
        end

        it 'sends out a confirmation sms for the admin user' do
          subject
          open_last_text_message_for ENV['TWILIO_NUMBER']
          expected = "An interview has been booked for #{selected_time}"
          expect(current_text_message.body).to eql expected
        end
      end

      context 'with eventid-decline' do
        let(:body) { "#{event.id}-decline" }

        it 'sends out a confirmation sms for this person' do
          subject
          open_last_text_message_for research_subject.phone_number
          expected = 'You have declined this invitation. Thanks for the heads-up.'
          expect(current_text_message.body).to eql expected
        end

        it 'sends out a confirmation sms for the admin user' do
          subject
          open_last_text_message_for ENV['TWILIO_NUMBER']
          expected = "#{research_subject.full_name} has declined the invitation for event #{event.id}. "
          expected << 'Thanks for the heads-up.'
          expect(current_text_message.body).to eql expected
        end
      end

      context 'with gibberish' do
        let(:body) { 'gibberish' }

        it 'sends out an error sms for this person' do
          subject
          open_last_text_message_for research_subject.phone_number
          expect(current_text_message.body).to eql "Sorry, that's not a valid option"
        end
      end

      context 'attempts to select a reserved slot' do
        let(:selected_number) { 'a' }
        let(:body) { "#{event.id}#{selected_number}" }
        let!(:time_slot) { event.available_time_slots.first }
        let(:reservation){
          V2::Reservation.create(person: research_subject_2,
                                 time_slot: time_slot)
        }
        let!(:selected_time) { time_slot.to_weekday_and_time }

        it 'does not create a new reservation' do
          reservation.save
          subject
          expect(V2::Reservation.count).to eq(1)
          open_last_text_message_for research_subject.phone_number
          not_expected = "An interview has been booked for #{selected_time}"
          expect(current_text_message.body).to_not eql not_expected
        end

        it 'resends available slots' do
          reservation.save
          subject
          open_last_text_message_for research_subject.phone_number
          message_body = current_text_message.body
          expect(message_body).to have_text(event.description)

          expected = event.time_slots.last.to_time_and_weekday
          expect(message_body).to have_text(expected)

          person_token = research_subject.token
          expect(message_body).to have_text(person_token)
        end
      end
    end
  end
end
