# == Schema Information
#
# Table name: v2_event_invitations
#
#  id              :integer          not null, primary key
#  v2_event_id     :integer
#  email_addresses :string(255)
#  description     :string(255)
#  slot_length     :string(255)
#  date            :string(255)
#  start_time      :string(255)
#  end_time        :string(255)
#  buffer          :integer          default(0), not null
#

class V2::EventInvitation < ActiveRecord::Base
  self.table_name = 'v2_event_invitations'

  # to pass ownership on to the events.
  attr_accessor :created_by

  belongs_to :event, class_name: '::V2::Event', foreign_key: :v2_event_id
  has_one :user, through: '::V2::Event'

  # we don't really need a join model, exceptionally HABTM is more appropriate
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :invitees, class_name: 'Person', join_table: :invitation_invitees_join_table
  # rubocop:enable Rails/HasAndBelongsToMany

  # TODO: do away with description, it's now a V2::Event attribute
  # TODO: no longer use email addresses here. Should be person_ids
  validates :email_addresses, :description, :slot_length, :date, :start_time, :end_time, presence: true

  before_validation :find_invitees_or_add_error
  before_save :build_event, if: :valid?

  def email_addresses_to_array
    @email_addresses_array ||= email_addresses.present? ? email_addresses.split(',') : []
  end

  private

    def build_event
      self.event = V2::Event.create(
        description: description,
        time_slots: break_time_window_into_time_slots,
        user_id: created_by || 1 # if nil, make admin owner
      )
    end

    def find_invitees_or_add_error
      return unless invitees.empty?

      email_addresses_to_array.each do |email_address|
        invitee = Person.find_by(email_address: email_address.strip.chomp)
        if invitee
          # this is where the join table is created, yes?
          invitees << invitee
        else
          errors.add(:email_addresses, 'One or more of the email addresses are not registered')
          break
        end
      end
    end

    def break_time_window_into_time_slots
      V2::TimeWindow.new(
        event_id: v2_event_id,
        slot_length: slot_length,
        date: date,
        start_time: start_time,
        end_time: end_time,
        buffer: buffer
      ).slots
    end
end
