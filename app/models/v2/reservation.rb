# == Schema Information
#
# Table name: v2_reservations
#
#  id                  :integer          not null, primary key
#  time_slot_id        :integer
#  person_id           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#  event_id            :integer
#  event_invitation_id :integer
#

# - potentially storing the state of the reservation:
#   * attended, cancelled, missed, etc.
#   * could be where we hang comments / prepaid cards
class V2::Reservation < ActiveRecord::Base
  self.table_name = 'v2_reservations'

  include AASM
  include Calendarable

  belongs_to :time_slot, class_name: '::V2::TimeSlot'
  belongs_to :person
  belongs_to :event, class_name: '::V2::Event'
  belongs_to :user
  belongs_to :event_invitation, class_name: '::V2::EventInvitation'

  # so users can take notes.
  has_many :comments, as: :commentable, dependent: :destroy

  validates :person, presence: true
  validates :user, presence: true
  # validates :event, presence: true
  # validates :event_invitation, presence: true

  # can't have the same time slot id twice.
  validates :time_slot, uniqueness: true, presence: true

  # one person can't have multiple reservations for the same event
  validates :person, uniqueness: { scope: :event_invitation }

  # these overlap validations are super tricksy.
  # do we check this here?
  # User can't book over themselves.

  validates 'v2_time_slots.start_time', 'v2_time_slots.end_time',
    overlap: {
      query_options: { includes: [:time_slot] },
      scope: 'user_id',
      exclude_edges: %w( v2_time_slots.start_time v2_time_slots.end_time ),
      message_title:  'Sorry!',
      message_content: 'This time is no longer available.'
    }

  # person can only have one reservation at a time.
  validates 'v2_time_slots.start_time', 'v2_time_slots.end_time',
    overlap: {
      query_options: { includes: :time_slot },
      scope: 'person_id',
      exclude_edges: %w( v2_time_slots.start_time v2_time_slots.end_time ),
      message_title:  'Sorry!',
      message_content: 'This time is no longer available.'
    }

  # not sure about all these delegations.
  delegate :start_time,  to: :time_slot, allow_nil: true
  delegate :end_time,    to: :time_slot, allow_nil: true

  delegate :title,       to: :event_invitation
  delegate :description, to: :event_invitation
  delegate :date,        to: :event_invitation
  delegate :slot_length, to: :event_invitation
  delegate :duration,    to: :event_invitation

  # reservations can move through states
  aasm do
    state :created, initial: true
    state :reminded
    state :confirmed
    state :cancelled
    state :rescheduled
    state :missed

    event :remind, after_commit: :send_reminder do
      transitions from: :created, to: :reminded
    end

    event :confirm, after_commit: :notify_about_confirmation do
      transitions from: [:created, :reminded], to: :confirmed
    end

    event :cancel, after_commit: :notify_about_cancellation do
      transitions from: [:created, :reminded, :confirmed], to: :cancelled
    end

    event :reschedule, after_commit: :notify_about_reschedule do
      transitions from: [:created, :reminded, :confirmed], to: :rescheduled
    end

    event :miss do
      transitions from: [:created, :reminded, :confirmed], to: :missed
    end
  end

  def send_reminder
  end

  def notify_about_confirmation
  end

  def notify_about_cancellation
  end

  def notify_about_reschedule
  end
end
