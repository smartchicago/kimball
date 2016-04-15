# == Schema Information
#
# Table name: v2_events
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  description :string(255)
#

class V2::Event < ActiveRecord::Base
  self.table_name = 'v2_events'

  has_many :time_slots, class_name: '::V2::TimeSlot'

  belongs_to :user

  validates :description, presence: true
  validates :time_slots, presence: true

  def available_time_slots
    available_time_slots = time_slots.find_all { |slot| !slot.reservation.present? }
    available_time_slots || []
  end
end
