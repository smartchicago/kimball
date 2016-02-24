class V2::TimeSlot < ActiveRecord::Base
  self.table_name = 'v2_time_slots'

  belongs_to :event, class_name: '::V2::Event'

  validates :start_time, presence: true
  validates :end_time,   presence: true

  def to_time_and_weekday
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')} #{start_time.strftime('%A %d')}"
  end

  def to_weekday_and_time
    "#{start_time.strftime('%A %d')} #{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end
end
