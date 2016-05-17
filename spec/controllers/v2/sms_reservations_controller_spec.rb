require 'rails_helper'

describe V2::SmsReservationsController do
  include SmsSpec::Helpers

  let(:twilio_phone_number) { ENV['TWILIO_SCHEDULING_NUMBER'] }

  let(:event_invitation) { FactoryGirl.create(:event_invitation) }
  let(:user) { event_invitation.user }
  let(:research_subject) { event_invitation.invitees.first }
  let(:research_subject_2) { event_invitation.invitees.last }
  let(:contact_method) {
    research_subject.preferred_contact_method = 'SMS'
    research_subject.save
    research_subject_2.preferred_contact_method = 'SMS'
    research_subject_2.save
  }
  let(:event) { event_invitation.event }
  let(:time_slot) { event.time_slots.first }

  before do
    clear_messages
  end

  after do
    # Timecop.return
  end

  describe 'POST #create' do
    describe 'research subject replies' do
      let(:message) { twiml_message(research_subject.phone_number, body, to: twilio_phone_number) }

      subject { post :create, message }

      context 'with existing time slot option' do
        let(:selected_number) { 'a' }
        let(:body) { "#{event.id}#{selected_number}" }
        let(:selected_time) { event.time_slots.first.start_datetime_human }

        it 'reserves the time slot for this person' do
          subject
          expect(event.time_slots.first.reservation).to_not be_nil
        end

        it 'sends out a confirmation sms for this person' do
          subject
          open_last_text_message_for research_subject.phone_number

          expected = "A #{event_invitation.duration / 60} minute interview has been booked for:\n#{selected_time}\nWith: #{event.user.name}, \nTel: #{event.user.phone_number}\n.You'll get a reminder that morning."
          expect(current_text_message.body).to eql expected
        end

        it 'sends out a confirmation sms for the admin user' do
          skip('We do not send sms to admin users')
          subject
          open_last_text_message_for ENV['TWILIO_SCHEDULING_NUMBER']
          expected = "A #{event_invitation.duration / 60} minute interview has been booked for #{selected_time}, with #{event.user.name}. \nTheir number is #{event.user.phone_number}\n. You'll get a reminder that morning."
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

        it 'sends out a confirmation email for the admin user' do
          skip('We do not send sms to admin users')
          subject
          open_last_text_message_for ENV['TWILIO_SCHEDULING_NUMBER']
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
          expect(current_text_message.body).to eql "Sorry, I didn't understand that! I'm just a computer..."
        end
      end

      context 'attempts to select a reserved slot' do
        let(:selected_number) { 'a' }
        let(:body) { "#{event.id}#{selected_number}" }
        let(:time_slot) { event.time_slots.first }
        let(:reservation){
          V2::Reservation.create(user: event_invitation.user,
                             event: event,
                             event_invitation: event_invitation,
                             time_slot: time_slot,
                             person: research_subject_2)
        }
        let!(:selected_time) { time_slot.start_datetime_human }

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

          expected_times = event.time_slots.last.slot_time_human
          expect(message_body).to have_text(expected_times)

          person_token = research_subject.token
          expect(message_body).to have_text(person_token)
        end
      end

      context 'confirming a reservation' do
        let(:body) { 'confirm' }
        let(:reservation){
          V2::Reservation.create(user: event_invitation.user,
                             event: event,
                             event_invitation: event_invitation,
                             time_slot: time_slot,
                             person: research_subject)
        }

        it 'responds with confirmation message' do
          Timecop.travel(reservation.time_slot.start_time - 1.hour)
          research_subject.preferred_contact_method = 'SMS'
          research_subject.save
          subject
          open_last_text_message_for research_subject.phone_number
          message_text = 'You have confirmed a'
          expect(current_text_message.body).to have_text(message_text)
          Timecop.return
        end
      end

      context 'Cancelling a reservation' do
        let(:body) { 'cancel' }
        let(:reservation){
          V2::Reservation.create(user: event_invitation.user,
                             event: event,
                             event_invitation: event_invitation,
                             time_slot: time_slot,
                             person: research_subject)
        }
        it 'responds with cancelled message' do
          Timecop.travel(reservation.time_slot.start_time - 1.hour)
          research_subject.preferred_contact_method = 'SMS'
          research_subject.save
          subject
          open_last_text_message_for research_subject.phone_number
          expect(current_text_message.body).to have_text 'has been cancelled'
          Timecop.return
        end
      end

      context 'Requesting the calendar' do
        let(:body) { 'Calendar' }
        let(:reservation){
          V2::Reservation.create(user: event_invitation.user,
                             event: event,
                             event_invitation: event_invitation,
                             time_slot: time_slot,
                             person: research_subject)
        }
        it 'responds with current reservations' do
          Timecop.travel(reservation.time_slot.start_time - 1.hour)
          research_subject.preferred_contact_method = 'SMS'
          research_subject.save
          subject
          research_subject.reload
          open_last_text_message_for research_subject.phone_number
          res_count = research_subject.v2_reservations.for_today_and_tomorrow.size
          msg = "You have #{res_count} reservation#{res_count >1 ? 's' : ''} soon."
          expect(current_text_message.body).to have_text(msg)
          Timecop.return
        end
      end
    end
  end
end
