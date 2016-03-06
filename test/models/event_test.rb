# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  description    :text
#  starts_at      :datetime
#  ends_at        :datetime
#  location       :text
#  address        :text
#  capacity       :integer
#  application_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  created_by     :integer
#  updated_by     :integer
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test 'should know about reservations' do
    assert_equal 2, events(:one).people.count
  end

end
