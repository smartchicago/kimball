# == Schema Information
#
# Table name: gift_cards
#
#  id               :integer          not null, primary key
#  gift_card_number :string(255)
#  expiration_date  :string(255)
#  person_id        :integer
#  notes            :string(255)
#  created_by       :integer
#  reason           :integer
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string(255)      default("USD"), not null
#  giftable_id      :integer
#  giftable_type    :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  batch_id         :string(255)
#  proxy_id         :integer
#

require 'csv'

class GiftCard < ActiveRecord::Base
  page 20
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

  validates_format_of :expiration_date, with: /\A(0|1)([0-9])\/([0-9]{2})\z/i, unless: proc { |c| c.expiration_date.blank? }

  validates_length_of :proxy_id, is: 4, unless: proc { |c| c.proxy_id.blank? }
  validates_numericality_of :proxy_id, unless: proc { |c| c.proxy_id.blank? }

  validates_presence_of :batch_id
  validates_uniqueness_of :gift_card_number, scope: :batch_id

  validates_format_of :gift_card_number, with: /\A([0-9]){4,5}\z/i
  validates_uniqueness_of :reason, scope: :person_id, if: "reason == 'signup'"

  # ransacker :created_at, type: :date do
  #   Arel.sql('date(created_at)')
  # end

  # Need to add validation to limit 1 signup per person

  def self.batch_create(post_content)
    # begin exception handling

    # begin a transaction on the gift card model
    GiftCard.transaction do
      # for each gift card record in the passed json
      JSON.parse(post_content).each do |gift_card_hash|
        # create a new gift card
        GiftCard.create!(gift_card_hash)
      end # json.parse
    end # transaction
  rescue
    Rails.logger('There was a problem.')
    # exception handling
  end  # batch_create

  def self.export_csv
    CSV.generate do |csv|
      csv_column_names =  ['Gift Card ID', 'Batch ID', 'Gift Card Number', 'Expiration Date', 'Reason', 'Person ID', 'Name', 'Address', 'Phone Number', 'Email']
      csv << csv_column_names
      all.find_each do |gift_card|
        this_person = gift_card.person
        row_items = [gift_card.id, gift_card.batch_id, gift_card.gift_card_number,  gift_card.expiration_date, gift_card.reason.titleize, this_person.id || '', this_person.full_name || '', this_person.address_fields_to_sentence || '']
        if this_person.phone_number.present?
          row_items.push(this_person.phone_number.phony_formatted(format: :national, spaces: '-'))
        else
          row_items.push('')
        end
        row_items.push(this_person.email_address)
        csv << row_items
      end
    end
  end
end
