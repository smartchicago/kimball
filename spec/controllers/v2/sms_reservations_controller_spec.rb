require 'rails_helper'

describe V2::SmsReservationsController do
  include SmsSpec::Helpers

  let(:twilio_phone_number) { ENV['TWILIO_NUMBER'] }
  let!(:event_invitation) { FactoryGirl.create(:event_invitation) }
  let(:research_subject) { event_invitation.invitees.first }
  # this is to ensure we create events. occasionally, the callback is too slow
  let(:event) { event_invitation.event }

  before do
    clear_messages
  end

  describe 'POST #create' do
    describe 'research subject replies' do
      let(:message) { twiml_message(research_subject.phone_number, body, to: twilio_phone_number) }

      subject { post :create, message }

      context 'with existing time slot option' do
        let(:selected_number) { 1 }
        let(:body) { "#{event.id}#{selected_number}" }
        let(:selected_time) { event.reload.time_slots.first.to_weekday_and_time }

        it 'reserves the time slot for this person' do
          subject
          event_invitation.reload
          event.reload
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

      context 'with 0' do
        let(:body) { "#{event.id}0" }

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
    end
  end
end
