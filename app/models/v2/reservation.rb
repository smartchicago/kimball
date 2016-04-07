# == Schema Information
#
# Table name: v2_reservations
#
#  id           :integer          not null, primary key
#  time_slot_id :integer
#  person_id    :integer
#

class V2::Reservation < ActiveRecord::Base
  self.table_name = 'v2_reservations'

  belongs_to :time_slot, class_name: '::V2::TimeSlot'
  belongs_to :person

  validates :person, presence: true
  validates :time_slot, presence: true
end
