require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "should know about reservations" do
    assert_equal 2, events(:one).people.count
  end
end
