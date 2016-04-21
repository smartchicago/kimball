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

  include Calendarable
  has_one :event_invitation, class_name: '::V2::EventInvitation', foreign_key: 'v2_event_id'
  has_many :time_slots, class_name: '::V2::TimeSlot'
  has_many :invitees, through: :event_invitations
  has_many :reservations, through: :time_slots
  belongs_to :user

  validates :description, presence: true
  validates :time_slots, presence: true

  # not sure about all this delegation
  delegate :date,        to: :event_invitation
  delegate :start_time,  to: :event_invitation
  delegate :end_time,    to: :event_invitation
  delegate :slot_length, to: :event_invitation
  delegate :duration,    to: :event_invitation
  delegate :buffer,      to: :event_invitation

  def available_time_slots
    available_time_slots = time_slots.find_all { |slot| !slot.reservation.present? }
    available_time_slots || []
  end

  # for calendaring
  def person
    nil
  end

end
