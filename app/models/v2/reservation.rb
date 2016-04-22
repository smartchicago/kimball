# == Schema Information
#
# Table name: v2_reservations
#
#  id           :integer          not null, primary key
#  time_slot_id :integer
#  person_id    :integer
#

# TODO: denormalize associated objects into Reservation
# - it's the final snapshot of all scheduling, source to be checked
# against constantly
# - associated objects should still be in place, for cancellations
# - potentially storing the state of the reservation:
#   * attended, cancelled, missed, etc.
#   * could be where we hang comments / prepaid cards
class V2::Reservation < ActiveRecord::Base
  self.table_name = 'v2_reservations'

  include Calendarable

  belongs_to :time_slot, class_name: '::V2::TimeSlot'
  has_one    :event, through: :time_slot
  has_one    :user,  through: :event
  has_one    :event_invitation, through: :event
  belongs_to :person

  # we almost always need the time_slots and event
  default_scope { includes(:time_slot, :event) }

  validates :person, presence: true
  validates :time_slot, presence: true

  # can't have the same time slot id twice.
  validates :time_slot, uniqueness: true

  # these overlap validations are super tricksy.
  # do we check this here?
  # User can't book over themselves.

  validates 'v2_time_slots.start_time', 'v2_time_slots.end_time',
    overlap: {
      query_options: { includes: [:time_slot, :event] },
      scope: { 'v2_events.user_id' => proc { |e| e.user_id } },
      exclude_edges: %w( v2_time_slots.start_time v2_time_slots.end_time ),
      message_title:  'Sorry!',
      message_content: 'This time is no longer available.'
    }

  # person can only have one reservation at a time.
  validates 'v2_time_slots.start_time', 'v2_time_slots.end_time',
    overlap: {
      query_options: { includes: :time_slot },
      scope: { 'v2_reservations.person_id' => proc { |reservation| reservation.person_id } },
      exclude_edges: %w( v2_time_slots.start_time v2_time_slots.end_time ),
      message_title:  'Sorry!',
      message_content: 'This time is no longer available.'
    }

  # not sure about all these delegations.
  delegate :start_time,  to: :time_slot, allow_nil: true
  delegate :end_time,    to: :time_slot, allow_nil: true
  delegate :event_id,    to: :time_slot, allow_nil: true

  delegate :user_id,     to: :user, allow_nil: true

  delegate :duration,    to: :event
  delegate :description, to: :event

  delegate :date,        to: :event_invitation
  delegate :slot_length, to: :event_invitation
  delegate :duration,    to: :event_invitation

end
