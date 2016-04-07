# == Schema Information
#
# Table name: v2_time_slots
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  start_time :datetime
#  end_time   :datetime
#

class V2::TimeSlot < ActiveRecord::Base
  self.table_name = 'v2_time_slots'

  belongs_to :event, class_name: '::V2::Event'
  has_one :reservation, class_name: '::V2::Reservation'

  validates :start_time, presence: true
  validates :end_time,   presence: true
  validates :start_time, :end_time, overlap: { exclude_edges: %w( start_time end_time ) }

  def to_time_and_weekday
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')} #{start_time.strftime('%A %d')}"
  end

  def to_weekday_and_time
    "#{start_time.strftime('%A %d')} #{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end
end
