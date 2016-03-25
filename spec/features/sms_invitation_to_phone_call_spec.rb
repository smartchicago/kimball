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

    expected = "Hello #{@research_subject.first_name},\n"

    expected << "#{event.description}\n"

    expected << "If you're available, would you so kind to select one of the possible times below,"
    expected << " by texting back its respective number?\n\n"

    expected << "#{event.id}0) Decline\n"
    event.available_time_slots.each_with_index do |slot, i|
      expected << "#{event.id}#{i+1}) #{slot.to_time_and_weekday}\n"
    end

    expected << "\nThanks in advance for you time!\n\n"

    # TODO: signature should be configurable
    expected << 'Best, Kimball team'

    expect(current_text_message.body).to eql expected
  end
end
