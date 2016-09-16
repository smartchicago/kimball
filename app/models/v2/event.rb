# == Schema Information
#
# Table name: v2_events
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class V2::Event < ActiveRecord::Base
  self.table_name = 'v2_events'
  has_paper_trail

  include Calendarable
  has_one :event_invitation, class_name: '::V2::EventInvitation', foreign_key: 'v2_event_id'
  has_many :time_slots, class_name: '::V2::TimeSlot'
  has_many :invitees, through: :event_invitations
  has_many :reservations, through: :time_slots
  belongs_to :user

  validates :description, presence: true
  # validates :user_id, presence: true
  # validates :time_slots, presence: true

  # not sure about all this delegation
  delegate :date,        to: :event_invitation
  delegate :start_time,  to: :event_invitation
  delegate :end_time,    to: :event_invitation
  delegate :slot_length, to: :event_invitation
  delegate :duration,    to: :event_invitation
  delegate :buffer,      to: :event_invitation
  delegate :title,       to: :event_invitation

  after_save :build_slots, if: :event_invitation

  def available_time_slots(person = nil)
    # if a person has a reservation there are no slots for them.
    return [] if !person.nil? && person.v2_reservations.find_by(event_id: id)

    available_slots = time_slots.includes(:reservation).find_all do |slot|
      !slot.reservation.present?
    end

    available_slots = filter_reservations([user, person].compact, available_slots)

    available_slots || []
  end

  private

    def filter_reservations(arr_obj, slots)
      return [] if slots.blank?

      res = arr_obj.map do |obj|
        obj.v2_reservations.joins(:time_slot).
          where('v2_time_slots.start_time >=?', Time.zone.now)
      end
      res.flatten!
      slots.to_a.delete_if do |slot|
        # if we find a reservation that overlaps!
        !res.find { |r| overlap?(r, slot) }.blank?
      end
    end

    def not_overlap?(one, other)
      !overlap?(one, other)
    end

    def overlap?(one, other)
      ((one.start_datetime - other.end_datetime) * (other.start_datetime - one.end_datetime) >= 0)
    end

    def build_slots
      event_invitation.build_event
    end
end
