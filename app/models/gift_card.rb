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
  validates_presence_of :amount
  validates_presence_of :reason

end
