require 'rails_helper'

feature 'SMS invitation to phone call' do
  include SmsSpec::Helpers

  before do
    clear_messages
    @research_subject = FactoryGirl.create(:person, preferred_contact_method: 'SMS')
  end

  scenario 'Texting a link to the invitation, successfully' do
    login_with_admin_user

    visit '/v2/event_invitations/new'

    fill_in "People's email addresses", with: @research_subject.email_address

    event_description = "We're looking for mothers between the age of 16-26 for a phone interview"

    fill_in 'Event description', with: event_description

    select '30 mins', from: 'Call length'

    fill_in 'Date', with: '02/02/2016'
    select '12:00', from: 'Start time'
    select '15:30', from: 'End time'

    click_button 'Send invitation'

    expect(page).to have_text 'Person was successfully invited.'

    event = V2::Event.last

    open_last_text_message_for @research_subject.phone_number

    slots=[]

    event.available_time_slots(@research_subject).each_with_index do |slot, i|
      slots << "'#{event.id}#{(i + 97).chr}' for #{slot.to_time_and_weekday}\n"
    end

    # should use the person's name.
    expect(current_text_message.body).to have_text(@research_subject.first_name)

    # should describe the event.
    expect(current_text_message.body).to have_text(event.description)

    # needs each slot to be in the message
    slots.each { |s| expect(current_text_message.body).to have_text(s) }
  end
end
