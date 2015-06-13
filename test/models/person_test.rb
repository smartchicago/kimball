require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  test "should create new from wufoo params" do
    new_person = Person.initialize_from_wufoo(wufoo_params)
    assert new_person.save
    assert_equal "Jim", new_person.first_name
    assert_equal "jim@example.com", new_person.email_address
    assert_equal "Chicago", new_person.city
    assert_equal "Either one", new_person.participation_type
    assert_not_nil new_person.signup_at
  end
  
  test "should map wufoo device description to correct id" do
    new_person = Person.initialize_from_wufoo(wufoo_params.update('Field39' => "Smart phone"))
    assert new_person.save
    assert_equal 2, new_person.primary_device_id
  end

  test "should map wufoo connection description to correct id" do
    new_person = Person.initialize_from_wufoo(wufoo_params.update('Field41' => "Magical Connection"))
    assert new_person.save
    assert_equal 2, new_person.primary_connection_id
  end
  test "should have a comment associated" do
    assert_equal 1, people(:one).comments.size
    assert_equal comments(:one).content, people(:one).comments.first.content
  end

  test "should know about events" do
    assert_equal 2, people(:one).events.count
    assert_equal 1, people(:two).events.count
  end

  test "can add a tag to a person" do
    assert !people(:one).tags.detect{ |tag| tag.name == "foo bar baz" } 
    
    people(:one).tags << Tag.new(name: "foo bar baz", created_by: users(:admin).id)
    people(:one).tags.reload
    assert people(:one).tags.detect{ |tag| tag.name == "foo bar baz" } 
  end
end
