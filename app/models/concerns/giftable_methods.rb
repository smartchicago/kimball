require 'active_support/concern'

module GiftableMethods

  extend ActiveSupport::Concern

  def signup_gc_sent
    signup_cards = gift_cards.where(reason: 'signup')

    # if self.gift_cards.where(reason: signup)
    # self.alertings.where("ends_at >= ? or ends_at is null", Time.now).order(:starts_at)
  end

end
