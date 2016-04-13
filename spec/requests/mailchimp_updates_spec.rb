require 'rails_helper'

RSpec.describe 'MailchimpUpdates', type: :request do
  # gotta login!
  before(:each) do
    user = FactoryGirl.create(:user)
    post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
  end

  describe 'GET /mailchimp_updates' do
    it 'can be viewed as an admin' do
      get mailchimp_updates_path
      expect(response).to have_http_status(200)
    end
  end
end
