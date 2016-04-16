# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  description    :text(65535)
#  starts_at      :datetime
#  ends_at        :datetime
#  location       :text(65535)
#  address        :text(65535)
#  capacity       :integer
#  application_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  created_by     :integer
#  updated_by     :integer
#

require 'faker'

FactoryGirl.define do
  factory :event, class: V2::Event do
    description 'Lorem ipsum for now'

    before(:create) do |event|
      event.time_slots << FactoryGirl.build_list(:time_slot, 3).each { |t| t.event_id = event.id }
    end

    trait :fully_booked do
      after(:create) do |event|
        event.time_slots.each { |slot| FactoryGirl.create(:reservation, time_slot: slot) }
      end
    end
  end
end
