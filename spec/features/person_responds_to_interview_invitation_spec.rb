require 'rails_helper'
require 'capybara/email/rspec'

feature 'Person responds to interview invitation' do
  before do
    clear_emails
    @event = FactoryGirl.create(:event)
    @person = FactoryGirl.create(:person)
  end

  scenario 'when no time slots are avaialble anymore' do
    send_invitation_email_for_event_then_book_all_event_time_slots

    expect(page).to have_content 'We are sorry, but no more time slots are available. Please contact insert_email_here to set up another interview'

    @event.time_slots.each do |time|
      expect(page).to_not have_content time.to_time_and_weekday
    end
  end

  scenario 'over email, successfully' do
    send_invitation_email_and_click_reservation_link

    @event.available_time_slots.each do |time|
      expect(page).to have_content time.to_time_and_weekday
    end

    find('#v2_reservation_time_slot_id_1').set(true)

    click_button 'Confirm reservation'

    selected_time = @event.available_time_slots.first.to_weekday_and_time

    expect(page).to have_content "An interview has been booked for #{selected_time}"

    admin_email = 'admin@what.host.should.we.have.here.com'
    research_subject_email = @person.email_address

    [admin_email, research_subject_email].each do |email_address|
      open_email(email_address)

      # TODO: substitute placeholder text
      expect(current_email).
        to have_content "An interview has been booked for #{selected_time}"
    end
  end

  scenario 'over email, but forgetting to select a time' do
    send_invitation_email_and_click_reservation_link

    click_button 'Confirm reservation'

    expect(page).to have_content "No time slot was selected, couldn't create the reservation"
  end
end

def send_invitation_email_and_click_reservation_link
  EventInvitationMailer.invite(
    from: 'admin@what.host.should.we.have.here.com',
    email_address: @person.email_address,
    event: @event,
    person: @person).deliver_now

  open_email(@person.email_address)

  current_email.click_link 'Please click to setup a time for your interview'
end

def send_invitation_email_for_event_then_book_all_event_time_slots
  @event.time_slots.each do |slot|
    slot.create_reservation(person: FactoryGirl.create(:person))
  end

  send_invitation_email_and_click_reservation_link
end
