require 'rails_helper'

RSpec.describe 'gift_cards/edit', type: :view do
  before(:each) do
    @gift_card = assign(:gift_card, FactoryGirl.create(:gift_card))
    @last_gift_card = assign(:last_gift_card,FactoryGirl.create(:gift_card,
      gift_card_number: Faker::Number.number(4),
      proxy_id: Faker::Number.number(4),
      reason: 2))
  end

  it 'renders the edit gift_card form' do
    render
    assert_select 'form[action=?][method=?]', gift_card_path(@gift_card), 'post' do
      assert_select 'input[name=?]', 'gift_card[gift_card_number]'

      assert_select 'input[name=?]', 'gift_card[batch_id]'

      assert_select 'input[name=?]', 'gift_card[person_id]'

      assert_select 'input[name=?]', 'gift_card[notes]'

      assert_select 'input[name=?]', 'gift_card[created_by]'
    end
  end
end
