require 'rails_helper'

RSpec.describe 'gift_cards/edit', type: :view do
  before(:each) do
    @gift_card = assign(:gift_card, GiftCard.create!(
                                      gift_card_number: 99996,
                                      person_id: 1,
                                      batch_id: 1,
                                      notes: 'MyString',
                                      created_by: 1,
                                      reason: 1,
                                      expiration_date: '11/22'
    ))
  end

  it 'renders the edit gift_card form' do
    render

    assert_select 'form[action=?][method=?]', gift_card_path(@gift_card), 'post' do
      assert_select 'input#gift_card_gift_card_number[name=?]', 'gift_card[gift_card_number]'

      assert_select 'input#gift_card_batch_id[name=?]', 'gift_card[batch_id]'

      assert_select 'input#gift_card_person_id[name=?]', 'gift_card[person_id]'

      assert_select 'input#gift_card_notes[name=?]', 'gift_card[notes]'

      assert_select 'input#gift_card_created_by[name=?]', 'gift_card[created_by]'

      assert_select 'input#gift_card_reason[name=?]', 'gift_card[reason]'
    end
  end
end
