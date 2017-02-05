require 'rails_helper'

RSpec.describe 'gift_cards/show', type: :view do
  before(:each) do
    @gift_card = assign(:gift_card, GiftCard.create!(
                                      gift_card_number: 12345,
                                      person_id: 2,
                                      notes: 'Notes',
                                      created_by: 3,
                                      reason: 'signup',
                                      expiration_date: '11/22'
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
