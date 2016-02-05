class V2::Reservation < ActiveRecord::Base
  self.table_name = 'v2_reservations'

  belongs_to :time_slot, class_name: '::V2::TimeSlot'
  belongs_to :person

  validates :person, presence: true
  validates :time_slot, presence: true
end
