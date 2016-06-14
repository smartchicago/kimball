require 'rails_helper'

RSpec.describe 'mailchimp_updates/index', type: :view do
  before(:each) do
    MailchimpUpdate.create!(
      raw_content: 'MyText',
      email: 'Email',
      update_type: 'Update Type',
      reason: 'Reason'
    )
    MailchimpUpdate.create!(
      raw_content: 'MyText',
      email: 'Email',
      update_type: 'Update Type',
      reason: 'Reason'
    )
    assign(:mailchimp_updates,  MailchimpUpdate.order('fired_at DESC').paginate(page: params[:page]))
  end

  it 'renders a list of mailchimp_updates' do
    render
    assert_select 'tr>td', text: 'Email'.to_s, count: 2
    assert_select 'tr>td', text: 'Update Type'.to_s, count: 2
    assert_select 'tr>td', text: 'Reason'.to_s, count: 2
  end
end
