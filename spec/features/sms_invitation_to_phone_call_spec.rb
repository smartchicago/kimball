require 'rails_helper'
require 'faker'
require_relative '../support/twilio_mocker'

feature 'SMS invitation to phone call' do
  before do
    stub_const('Twilio::REST::Client', TwilioMocker)
    TwilioMocker.messages = []
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

    last_message = TwilioMocker.messages.last

    invitation_link = new_v2_reservation_url(
      email_address: @research_subject.email_address,
      event_id: Event.last.id,
      token: @research_subject.token
    )

    expected = <<-SMS
Hello, you've been invited to a phone interview

#{invitation_link}
    SMS

    expect(last_message.body).to eql expected
  end
end
