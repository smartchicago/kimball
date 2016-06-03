require 'rails_helper'

RSpec.describe "gift_cards/show", type: :view do
  before(:each) do
    @gift_card = assign(:gift_card, GiftCard.create!(
      :last_four => 1,
      :person_id => 2,
      :notes => "Notes",
      :created_by => 3,
      :reason => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Notes/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
