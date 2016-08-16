require 'rails_helper'
require 'faker'

feature 'People registration' do
  scenario 'with valid data' do
    visit '/registration'

    expect { complete_form_with_valid_data }.to change(Person, :count).by(1)
    # expect(page).to have_text('Person was successfully created.')
  end

  scenario 'with invalid data' do
    visit '/registration'

    complete_form_with_invalid_data

    expect(page).to have_text('Oops! Looks like something went wrong.')
  end
end

def complete_form_with_invalid_data
  click_button 'Save'
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def complete_form_with_valid_data
  person = FactoryGirl.build(:person)
  fill_in 'First name', with: person.first_name
  fill_in 'Last name', with: person.last_name
  fill_in 'Email address', with: person.email_address
  select 'Email', from: 'Preferred contact method'
  fill_in 'Phone number', with: person.email_address

  # DIG members are uncomfortable with providing addresses

  # fill_in 'Address 1', with: person.address_1
  # fill_in 'Address 2', with: person.address_2
  # fill_in 'City', with: person.city
  # fill_in 'State', with: person.state
  fill_in 'Postal code', with: person.postal_code

  # this is discerned through phone screening
  # select 'desktop', from: 'Primary device'
  # fill_in 'Primary device description', with: person.primary_device_description

  # select 'tablet', from: 'Secondary device'
  # fill_in 'Secondary device description', with: person.secondary_device_description

  # select 'Home broadband', from: 'Primary connection'
  # fill_in 'Primary connection description', with: 'so so'

  # select 'Phone', from: 'Secondary connection'
  # fill_in 'Secondary connection description', with: 'worse'

  # fill_in 'Participation type', with: 'remote'

  click_button 'Save'
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
