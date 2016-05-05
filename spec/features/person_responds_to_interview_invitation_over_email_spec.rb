require 'rails_helper'
require 'capybara/email/rspec'

feature 'Person responds to interview invitation over email' do
  before do
    clear_emails
    @event_invitation = FactoryGirl.create(:event_invitation)
    @event = @event_invitation.event
    @research_subject = @event_invitation.invitees.first
  end

  scenario 'successfully' do
    receive_invitation_email_and_click_reservation_link
    @event.available_time_slots.each do |time|
      expect(page).to have_content time.to_time_and_weekday
    end
    selected_time = @event.available_time_slots.first.to_weekday_and_time
    first_slot = @event.available_time_slots.first

    find("#v2_reservation_time_slot_id_#{first_slot.id}").set(true)
    click_button 'Confirm reservation'

    expect(page).to have_content "An interview has been booked for #{selected_time}"

    admin_email = @event.user.email
    research_subject_email = @research_subject.email_address

    [admin_email, research_subject_email].each do |email_address|
      open_email(email_address)

      # TODO: substitute placeholder text
      expect(current_email).
        to have_content "An interview has been booked for #{selected_time}"
      expect(current_email.attachments.length).to eq(1)
      attachment = current_email.attachments[0]
      expect(attachment).to be_a_kind_of(Mail::Part)
      expect(attachment.content_type).to start_with('application/ics')
      expect(attachment.filename).to eq('event.ics')
    end
  end

  scenario 'but forgetting to select a time' do
    receive_invitation_email_and_click_reservation_link

    click_button 'Confirm reservation'

    expect(page).to have_content "No time slot was selected, couldn't create the reservation"
  end

  scenario 'when no time slots are avaialble anymore' do
    send_invitation_email_for_event_then_book_all_event_time_slots

    expect(page).to have_content 'We are sorry, but no more time slots are available.'

    @event.time_slots.each do |time|
      expect(page).to_not have_content time.to_time_and_weekday
    end
  end
end

def receive_invitation_email_and_click_reservation_link
  @event.reload
  EventInvitationMailer.invite(
    email_address: @research_subject.email_address,
    event: @event,
    person: @research_subject).deliver_now

  open_email(@research_subject.email_address)

  current_email.click_link 'Please click to setup a time for your interview'
end

def send_invitation_email_for_event_then_book_all_event_time_slots
  @event.reload
  @event.time_slots.each_with_index do |slot, i|
    V2::Reservation.create(person: @event_invitation.invitees[i],
                           time_slot: slot,
                           user: @event_invitation.user,
                           event: @event_invitation.event,
                           event_invitation: @event_invitation)
  end

  receive_invitation_email_and_click_reservation_link
end
