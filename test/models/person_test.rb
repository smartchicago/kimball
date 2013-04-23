require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  test "should create new from wufoo params" do
    new_person = Person.initialize_from_wufoo(wufoo_params)
    assert new_person.save
    assert_equal "Jim", new_person.first_name
    assert_equal "jim@example.com", new_person.email_address
    assert_equal "Chicago", new_person.city
    assert_not_nil new_person.signup_at
  end
  
  test "should map wufoo device description to correct id" do
    new_person = Person.initialize_from_wufoo(wufoo_params.update('Field20' => "Smart phone"))
    assert new_person.save
    assert_equal 2, new_person.primary_device_id
  end

  test "should have a comment associated" do
    assert_equal 1, people(:one).comments.size
    assert_equal comments(:one).content, people(:one).comments.first.content
  end
end
