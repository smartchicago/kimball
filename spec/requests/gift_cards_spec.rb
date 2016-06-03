require 'rails_helper'

RSpec.describe "GiftCards", type: :request do
  describe "GET /gift_cards" do
    it "works! (now write some real specs)" do
      get gift_cards_path
      expect(response).to have_http_status(200)
    end
  end
end
