require 'rails_helper'
require 'capybara/email/rspec'
require 'support/poltergeist_js_hack_for_login'
require 'capybara/email/rspec'

@default_url_options = ActionMailer::Base.default_url_options

feature 'Person responds to interview invitation over email' do
  before do
    clear_emails
    @event_invitation = FactoryGirl.create(:event_invitation)
    @event = @event_invitation.event
    @research_subject = @event_invitation.invitees.first
    # we need the link in our emails to be the capybara server!
    ActionMailer::Base.default_url_options = {
      host: Capybara.current_session.server.host,
      port: Capybara.current_session.server.port
    }
  end

  after do
    # undo our prior madness
    ActionMailer::Base.default_url_options = @default_url_options
  end

  scenario 'successfully', js: :true  do
    receive_invitation_email_and_click_reservation_link
    @event.available_time_slots.each do |time|
      expect(page).to have_content time.start_time.strftime('%l:%M')
      expect(page).to have_content time.end_time.strftime('%l:%M')
    end

    first_slot = @event.available_time_slots.first
    start_time = first_slot.start_time.strftime('%l:%M').delete(' ')

    find("div[data-start='#{start_time}']").click
    expect(page).to have_content(@event.description)
    expect(page).to have_content(@event.title)
    click_button('Select')
    sleep 1
    selected_time = first_slot.to_weekday_and_time
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

  scenario 'when no time slots are avaialble anymore', js: :true do
    book_all_event_time_slots
    receive_invitation_email_and_click_reservation_link

    @event.available_time_slots.each do |time|
      expect(page).not_to have_content time.start_time.strftime('%l:%M')
      expect(page).not_to have_content time.end_time.strftime('%l:%M')
    end
  end

  scenario 'when time slots are not longer avaialble', js: :true do
    receive_invitation_email_and_click_reservation_link
    first_slot = @event.available_time_slots.first
    book_all_event_time_slots
    @event.available_time_slots.each do |time|
      expect(page).to have_content time.start_time.strftime('%l:%M')
      expect(page).to have_content time.end_time.strftime('%l:%M')
    end

    start_time = first_slot.start_time.strftime('%l:%M').delete(' ')

    find("div[data-start='#{start_time}']").click
    expect(page).to have_content(@event.description)
    expect(page).to have_content(@event.title)

    click_button('Select')
    sleep 1
    expect(page).to have_content "No time slot was selected, couldn't create the reservation"
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

def book_all_event_time_slots
  @event.reload
  @event.time_slots.each_with_index do |slot, i|
    V2::Reservation.create(person: @event_invitation.invitees[i],
                           time_slot: slot,
                           user: @event_invitation.user,
                           event: @event_invitation.event,
                           event_invitation: @event_invitation)
  end
end
