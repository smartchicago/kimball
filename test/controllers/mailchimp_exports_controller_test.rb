# == Schema Information
#
# Table name: mailchimp_exports
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  body       :text(65535)
#  created_by :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class MailchimpExportsControllerTest < ActionController::TestCase

  test 'should get index' do
    get :index
    assert_response :success
  end

end
