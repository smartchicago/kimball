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
  validates_presence_of :amount
  validates_presence_of :reason
  validates_format_of :expiration_date, with: /\A(0|1)([0-9])\/(2[0-9]{3})\z/i

  # Need to add validation to limit 1 signup per person

  def self.batch_create(post_content)
    # begin exception handling
    begin
      # begin a transaction on the gift card model
      GiftCard.transaction do
        # for each gift card record in the passed json
        JSON.parse(post_content).each do |gift_card_hash|
          # create a new gift card
          GiftCard.create!(gift_card_hash)
        end # json.parse
      end # transaction
    rescue
      Rails.logger("There was a problem.")
    end  # exception handling
  end  # batch_create

end
