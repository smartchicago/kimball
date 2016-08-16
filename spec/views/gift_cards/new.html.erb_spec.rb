require 'rails_helper'

RSpec.describe 'gift_cards/new', type: :view do
  before(:each) do
    assign(:gift_card, GiftCard.new(
                         last_four: 1,
                         person_id: 1,
                         notes: 'MyString',
                         created_by: 1,
                         reason: 1
    ))
  end

  it 'renders new gift_card form' do
    render

    assert_select 'form[action=?][method=?]', gift_cards_path, 'post' do
      assert_select 'input#gift_card_last_four[name=?]', 'gift_card[last_four]'

      assert_select 'input#gift_card_person_id[name=?]', 'gift_card[person_id]'

      assert_select 'input#gift_card_notes[name=?]', 'gift_card[notes]'

      assert_select 'input#gift_card_created_by[name=?]', 'gift_card[created_by]'

      assert_select 'input#gift_card_reason[name=?]', 'gift_card[reason]'
    end
  end
end
