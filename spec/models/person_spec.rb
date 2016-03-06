require 'rails_helper'

describe Person do
  subject { FactoryGirl.build(:person) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  # We don't want to force people to fill this out. not yet
  # it { is_expected.to validate_presence_of(:primary_device_id) }
  # it { is_expected.to validate_presence_of(:primary_device_description) }
  # it { is_expected.to validate_presence_of(:primary_connection_id) }
  it { is_expected.to validate_presence_of(:postal_code) }
  it { is_expected.to validate_uniqueness_of(:email_address) }
  # Not working with shoulda-matchers 3.1.0
  # it { is_expected.to validate_uniqueness_of(:phone_number) }

  it 'validates uniqueness of phone_number' do
    expect(subject).to be_valid
    another_person = FactoryGirl.create(:person)
    subject.phone_number = another_person.phone_number
    expect(subject).to_not be_valid
  end

  it 'requires either a phone number or an email to be present' do
    expect(subject).to be_valid
    subject.email_address = ''
    expect(subject).to be_valid
    subject.phone_number = ''
    expect(subject).to_not be_valid
    subject.email_address = 'jessica@jones.com'
    expect(subject).to be_valid
  end
end
