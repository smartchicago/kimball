require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  test "should create new from wufoo params" do
    new_person = Person.initialize_from_wufoo(wufoo_params)
    assert new_person.save
    assert_equal "Jim", new_person.first_name
    assert_equal "jim@example.com", new_person.email_address
  end
end
