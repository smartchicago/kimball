class V2::EventInvitation
  include ActiveModel::Model

  attr_accessor :email_addresses, :description, :slot_length, :date, :start_time, :end_time
  attr_reader   :event

  validates :email_addresses, :description, :slot_length, :date, :start_time, :end_time, presence: true
  validate :emails_are_registered

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

  def email_addresses_to_array
    email_addresses.present? ? email_addresses.split(',') : []
  end

  private

    def emails_are_registered
      if (email_addresses_to_array.size > 0) && unregistered_emails_present?
        errors.add(:email_addresses, 'One or more of the email addresses are not registered')
      end
    end

    def unregistered_emails_present?
      email_addresses_to_array.each do |email_address|
        return true unless Person.where(email_address: email_address).count > 0
      end
      false
    end

    def time_slots
      V2::TimeWindow.new(
        slot_length: slot_length,
        date: date,
        start_time: start_time,
        end_time: end_time
      ).slots
    end
end
