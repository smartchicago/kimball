class V2::Event < ActiveRecord::Base
  self.table_name = 'v2_events'

  has_many :time_slots, class_name: '::V2::TimeSlot'

  validates :description, presence: true
  validates :time_slots, presence: true

  def available_time_slots
    available_time_slots = time_slots.find_all { |slot| !slot.reservation.present? }
    available_time_slots || []
  end
end
