# == Schema Information
#
# Table name: applications
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  description  :text
#  url          :string(255)
#  source_url   :string(255)
#  creator_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  program_id   :integer
#  created_by   :integer
#  updated_by   :integer
#

require 'test_helper'

class ApplicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
