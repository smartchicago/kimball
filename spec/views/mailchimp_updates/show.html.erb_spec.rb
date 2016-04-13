require 'rails_helper'

RSpec.describe "mailchimp_updates/show", type: :view do
  before(:each) do
    @mailchimp_update = assign(:mailchimp_update, MailchimpUpdate.create!(
      :raw_content => "MyText",
      :email => "Email",
      :update_type => "Update Type",
      :reason => "Reason"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Update Type/)
    expect(rendered).to match(/Reason/)
  end
end
