# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  password_salt          :string(255)
#  invitation_token       :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  approved               :boolean          default(FALSE), not null
#  name                   :string(255)
#  token                  :string(255)
#

class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, stretches: 10

  has_many :v2_events, class_name: '::V2::Event'
  has_many :event_invitations, class_name: '::V2::EventInvitation', through: :v2_events
  has_many :v2_reservations, through: :v2_events, source: :reservations

  has_secure_token # for calendar feeds

  # for sanity's sake
  alias_attribute :email_address, :email

  def active_for_authentication?
    if super && approved?
      true
    else
      Rails.logger.warn("[SEC] User #{email} is not approved but attempted to authenticate.")
      false
    end
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def approve!
    update_attributes(approved: true)
    Rails.logger.info("Approved user #{email}")
  end

  def unapprove!
    update_attributes(approved: false)
    Rails.logger.info("Unapproved user #{email}")
  end

  def reservations
    v2_reservations
  end

  def events
    v2_events
  end

  def full_name # convienence for calendar view.
    name
  end

  def self.send_all_reminders
    # this is where reservation_reminders
    # called by whenever in /config/schedule.rb
    User.all.find_each(&:send_reservation_reminder)
  end

  def send_reservation_reminder
    return if v2_reservations.for_today.size == 0
    ReservationNotifier.remind(
      reservations:  v2_reservations.for_today,
      person: email
    ).deliver_later
  end
end
