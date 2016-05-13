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
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer
#

class V2::EventInvitation < ActiveRecord::Base
  self.table_name = 'v2_event_invitations'

  include Calendarable

  belongs_to :event, class_name: '::V2::Event', foreign_key: :v2_event_id
  belongs_to :user

  attr_accessor :thing

  # we don't really need a join model, exceptionally HABTM is more appropriate
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :invitees, class_name: 'Person', join_table: :invitation_invitees_join_table
  # rubocop:enable Rails/HasAndBelongsToMany

  # TODO: no longer use email addresses here. Should be person_ids
  validates :people_ids, :description, :title, :slot_length, :date, :start_time, :end_time, :user_id, presence: true

  before_validation :find_invitees_or_add_error
  before_save :build_event, if: :valid?

  default_scope { includes(:event) }

  # people_ids should be a postgres array type.
  # http://blog.plataformatec.com.br/2014/07/rails-4-and-postgresql-arrays/
  def people_ids_to_array
    @people_ids_array ||= people_ids.present? ? people_ids.split(',').map(&:to_i) : []
  end

  def people
    Person.where(id: people_ids_to_array)
  end

  def duration
    slot_length.delete(' mins').to_i.minutes
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

  # this caused the heisenbug.
  # the event would be invalid, because it didn't have slots
  # this now creates an event on save and if the event doesn't have slots

  def build_event
    self.event = V2::Event.create(
      description: description,
      time_slots: break_time_window_into_time_slots,
      user_id: user_id
    )
  end

  def invitees_name_and_id
    return [] if invitees.nil?
    invitees.map { |i| { id: i.id, name: i.full_name, label: i.full_name, value: i.id } }
  end

  def people_name_and_id
    return [] if people_ids.nil?
    people.map { |i| { id: i.id, name: i.full_name, label: i.full_name, value: i.id } }
  end

  private

    def find_invitees_or_add_error
      return unless invitees.empty?

      people_ids_to_array.each do |person_id|
        invitee = Person.find_by(id: person_id.strip.chomp)
        if invitee
          # this is where the join table is created, yes?
          invitees << invitee
        else
          errors.add(:people_ids, 'One or more of the people are not registered')
          break
        end
      end
    end

end
