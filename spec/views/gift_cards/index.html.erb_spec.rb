require 'rails_helper'

RSpec.describe "gift_cards/index", type: :view do
  before(:each) do
    assign(:gift_cards, [
      GiftCard.create!(
        :last_four => 1,
        :person_id => 2,
        :notes => "Notes",
        :created_by => 3,
        :reason => 4
      ),
      GiftCard.create!(
        :last_four => 1,
        :person_id => 2,
        :notes => "Notes",
        :created_by => 3,
        :reason => 4
      )
    ])
  end

  it "renders a list of gift_cards" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Notes".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
