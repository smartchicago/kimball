# == Schema Information
#
# Table name: mailchimp_exports
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  body       :text
#  created_by :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class MailchimpExportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
