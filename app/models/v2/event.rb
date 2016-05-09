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
      arr_obj.each do |obj|
        # obj.reload
        slots = filter_obj_reservations(obj, slots)
      end
      slots
    end

    def filter_obj_reservations(obj, slots)
      unless slots.empty?
        res = obj.v2_reservations.joins(:time_slot).
              where('v2_time_slots.start_time >=?',
                Time.zone.now)

        # TODO: refactor
        # filtering out slots that overlap. Tricky.
        slots = slots.select do |s|
          res.any? { |r| not_overlap?(r, s) }
        end unless res.empty?
      end
      slots
    end

    def not_overlap?(one, other)
      !((one.start_time - other.end_time) * (other.start_time - one.end_time) >= 0)
    end

    def build_slots
      event_invitation.build_event
    end
end
