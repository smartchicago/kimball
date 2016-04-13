require 'rails_helper'

RSpec.describe "mailchimp_updates/edit", type: :view do
  before(:each) do
    @mailchimp_update = assign(:mailchimp_update, MailchimpUpdate.create!(
      :raw_content => "MyText",
      :email => "MyString",
      :update_type => "MyString",
      :reason => "MyString"
    ))
  end

  it "renders the edit mailchimp_update form" do
    render

    assert_select "form[action=?][method=?]", mailchimp_update_path(@mailchimp_update), "post" do

      assert_select "textarea#mailchimp_update_raw_content[name=?]", "mailchimp_update[raw_content]"

      assert_select "input#mailchimp_update_email[name=?]", "mailchimp_update[email]"

      assert_select "input#mailchimp_update_update_type[name=?]", "mailchimp_update[update_type]"

      assert_select "input#mailchimp_update_reason[name=?]", "mailchimp_update[reason]"
    end
  end
end
