require 'rails_helper'
require 'faker'
require 'support/poltergeist_js_hack_for_login'
require 'capybara/email/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

feature 'Invite a person to a phone call' do
  scenario 'with valid data' do
    login_with_admin_user

    visit '/v2/event_invitations/new'

    research_subject_email = 'person@test.com.br'
    admin_email = 'admin@what.host.should.we.have.here.com'

    fill_in "Person's email address", with: research_subject_email

    # TODO: allow to fill in multiple email addresses once basic invitation works

    event_description = "We're looking for mothers between the age of 16-26 for a phone interview"

    fill_in 'Event description', with: event_description

    select '30 mins', from: 'Call length'

    fill_in 'Date', with: '02/02/2016'
    select '12:00', from: 'Start time'
    select '15:30', from: 'End time'

    # TODO: implement multiple time windows after invitation for single time window works
    #
    # click_link 'Add another time window'
    #
    # fill_in 'Date', with: '02/03/2016'
    # select '12:00', from: 'Start time'
    # select '14:30', from: 'End time'

    click_button 'Send invitation'

    expect(page).to have_text 'Person was successfully invited.'

    [research_subject_email, admin_email].each do |email_address|
      open_email(email_address)

      expect(current_email).
        to have_content "Hello, you've been invited to a phone interview"

      expect(current_email).
        to have_content event_description
    end
  end

  scenario 'with invalid data' do
    login_with_admin_user

    visit '/v2/event_invitations/new'

    click_button 'Send invitation'

    expect(page).to have_text('There were problems with some of the fields.')
  end

  scenario 'with a call length that doesnt fit the time window perfectly, show a confirmation window', js: :true do
    login_with_admin_user

    visit '/v2/event_invitations/new'

    select '30 mins', from: 'Call length'

    fill_in 'Date', with: '20/02/2016'
    select '12:00', from: 'Start time'
    select '13:15', from: 'End time'

    click_button 'Send invitation'
    message = dismiss_confirm do
      click_button 'Send invitation'
    end
    expect(message).to eq('Your time window is not a multiple of the call length. Do you still want to save the Event?')
  end

  scenario 'with an end time that falls before the start time', js: :true do
    login_with_admin_user

    visit '/v2/event_invitations/new'

    select '13:00', from: 'Start time'
    select '12:15', from: 'End time'

    click_button 'Send invitation'
    message = accept_alert do
      click_button 'Send invitation'
    end
    expect(message).to eq('Please make sure that the End time is greater than the Start time')
  end
end

def login_with_admin_user
  user = FactoryGirl.create(:user)
  visit '/users/sign_in'
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign in'
end
