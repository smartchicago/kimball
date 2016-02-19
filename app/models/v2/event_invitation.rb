class V2::EventInvitation
  include ActiveModel::Model

  attr_accessor :email_addresses, :description, :slot_length, :date, :start_time, :end_time
  attr_reader   :event

  validates :email_addresses, :description, :slot_length, :date, :start_time, :end_time, presence: true

  def save
    if valid?
      @event = V2::Event.new(
        description: description,
        time_slots: time_slots
      )

      @event.save!
    else
      false
    end
  end

  private

    def time_slots
      V2::TimeWindow.new(
        slot_length: slot_length,
        date: date,
        start_time: start_time,
        end_time: end_time
      ).slots
    end
end
