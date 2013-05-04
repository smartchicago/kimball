require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase
  test "should return form field count" do
    assert_equal 5, submissions(:one).fields.size
  end
  
  test "should return a field label" do
    assert_equal 'Email', submissions(:one).field_label('Field113')
  end
  
  test "should return a field value" do
    assert_equal '0000@example.com', submissions(:one).field_value('Field113')
  end
  
  test "should parse subfields" do
    assert submissions(:one).field_value('Field10').include?("Thusday, May 30")
  end  
end