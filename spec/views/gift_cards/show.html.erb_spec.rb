require 'rails_helper'

RSpec.describe 'gift_cards/show', type: :view do
  before(:each) do
    @person = FactoryGirl.create(:person)
    @user = FactoryGirl.create(:user)
    @gift_card = assign(:gift_card, GiftCard.create!(
                                      gift_card_number: 12345,
                                      person_id: @person.id,
                                      notes: 'Notes',
                                      created_by: @user.id,
                                      proxy_id: '4567',
                                      batch_id: 1,
                                      reason: 'signup',
                                      expiration_date: '11/22'
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/1/)

    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/4567/)
  end
end
