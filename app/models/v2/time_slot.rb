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

  include Calendarable
  belongs_to :event, class_name: '::V2::Event'
  has_one :user, through: :event
  has_one :event_invitation, through: :event
  has_one :reservation, class_name: '::V2::Reservation'
  has_one :person, through: :reservation

  validates :start_time, presence: true
  validates :end_time,   presence: true

  delegate :date,        to: :event_invitation
  delegate :description, to: :event
  delegate :duration,    to: :event_invitation
  delegate :slot_legnth, to: :event_invitation

  # this is also tricky: timeslots for the same event can't overlap
  # but two users can create two events with overlapping timeslots.
  validates :start_time, :end_time, overlap: { exclude_edges: %w( start_time end_time ), scope: 'event_id' }

  # this is tricky. Slots can't overlap for an event or reservation
  # validates :start_time, :end_time, overlap: { exclude_edges: %w( start_time end_time ), scope: :reservation }

  def to_time_and_weekday
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')} #{start_time.strftime('%A %d')}"
  end

  def to_weekday_and_time
    "#{start_time.strftime('%A %d')} #{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

end
