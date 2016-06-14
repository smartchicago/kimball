# == Schema Information
#
# Table name: mailchimp_updates
#
#  id          :integer          not null, primary key
#  raw_content :text(65535)
#  email       :string(255)
#  update_type :string(255)
#  reason      :string(255)
#  fired_at    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'faker'
FactoryGirl.define do
  factory :mailchimp_update do
    raw_content 'MyText'
    email { Faker::Internet.email }
    update_type 'MyString'
    reason 'MyString'
    fired_at '2016-03-30 13:01:21'
  end
end
