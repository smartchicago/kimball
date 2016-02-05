class V2::Event < ActiveRecord::Base
  has_many :time_slots, class_name: '::V2::TimeSlot'

  validates :description, presence: true
  validates :time_slots, presence: true
end
