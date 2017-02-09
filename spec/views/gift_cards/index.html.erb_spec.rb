require 'rails_helper'

RSpec.describe 'gift_cards/index', type: :view do
  before(:each) do
    person = FactoryGirl.create(:person)
    a = GiftCard.create!(
      gift_card_number: 12345,
      batch_id: 1,
      proxy_id: '0432',
      person_id: person.id,
      notes: 'Notes',
      created_by: 3,
      reason: 'signup',
      expiration_date: '11/22'
    )
    b = GiftCard.create!(
      gift_card_number: 12346,
      batch_id: 1,
      proxy_id: '4321',
      person_id: person.id,
      notes: 'Notes',
      created_by: 3,
      reason: 'interview',
      expiration_date: '11/22'
    )
    assign(:gift_cards, GiftCard.paginate(page: 1, per_page: 5).find([a.id, b.id]))
    ## this is an ugly hack to get this to
    assign(:recent_signups, GiftCard.paginate(page: 1, per_page: 5))
    assign(:q_recent_signups, Person.ransack)
    assign(:new_gift_cards, [])
    assign(:q_giftcards, GiftCard.ransack)
  end

  it 'renders a list of gift_cards' do
    render

    assert_select 'tr>td', text: '0432', count: 1
    assert_select 'tr>td', text: '4321', count: 1
    assert_select 'tr>td', text: 12345.to_s, count: 1
    assert_select 'tr>td', text: 12346.to_s, count: 1
    assert_select 'tr>td', text: 'Signup', count: 1
    assert_select 'tr>td', text: 'Interview', count: 1
  end
end
