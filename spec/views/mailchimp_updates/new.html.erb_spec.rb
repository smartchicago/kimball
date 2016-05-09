require 'rails_helper'

RSpec.describe "mailchimp_updates/new", type: :view do
  before(:each) do
    assign(:mailchimp_update, MailchimpUpdate.new(
      :raw_content => "MyText",
      :email => "MyString",
      :update_type => "MyString",
      :reason => "MyString"
    ))
  end

  it "renders new mailchimp_update form" do
    render

    assert_select "form[action=?][method=?]", mailchimp_updates_path, "post" do

      assert_select "textarea#mailchimp_update_raw_content[name=?]", "mailchimp_update[raw_content]"

      assert_select "input#mailchimp_update_email[name=?]", "mailchimp_update[email]"

      assert_select "input#mailchimp_update_update_type[name=?]", "mailchimp_update[update_type]"

      assert_select "input#mailchimp_update_reason[name=?]", "mailchimp_update[reason]"
    end
  end
end
