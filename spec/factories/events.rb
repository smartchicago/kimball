require 'faker'

FactoryGirl.define do
  factory :event, class: V2::Event do
    description 'Lorem ipsum for now'

    before(:create) do |event|
      # create_list(:time_slot, 3, event: event)
      3.times { event.time_slots << FactoryGirl.create(:time_slot) }
    end
  end
end
