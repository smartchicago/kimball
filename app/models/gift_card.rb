class GiftCard < ActiveRecord::Base

  monetize :amount_cents

  enum reason: {
    unknown: 0,
    signup: 1,
    test: 2,
    referral: 3,
    interview: 4,
    other: 5
  }

  belongs_to :giftable, polymorphic: true, touch: true
  belongs_to :person
  belongs_to :user
  validates_presence_of :amount
  validates_presence_of :reason
  validates_format_of :expiration_date, with: /\A(0|1)([0-9])\/(2[0-9]{3})\z/i

  validates_uniqueness_of :reason, scope: :person_id if -> { reason == 'signup' }
  # Need to add validation to limit 1 signup per person

end
