# == Schema Information
#
# Table name: people
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  last_name                        :string(255)
#  email_address                    :string(255)
#  address_1                        :string(255)
#  address_2                        :string(255)
#  city                             :string(255)
#  state                            :string(255)
#  postal_code                      :string(255)
#  geography_id                     :integer
#  primary_device_id                :integer
#  primary_device_description       :string(255)
#  secondary_device_id              :integer
#  secondary_device_description     :string(255)
#  primary_connection_id            :integer
#  primary_connection_description   :string(255)
#  phone_number                     :string(255)
#  participation_type               :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  signup_ip                        :string(255)
#  signup_at                        :datetime
#  voted                            :string(255)
#  called_311                       :string(255)
#  secondary_connection_id          :integer
#  secondary_connection_description :string(255)
#  verified                         :string(255)
#  preferred_contact_method         :string(255)
#  token                            :string(255)
#  active                           :boolean          default(TRUE)
#  deactivated_at                   :datetime
#  deactivated_method               :string(255)
#  neighborhood                     :string(255)
#  tag_count_cache                  :integer          default(0)
#

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
