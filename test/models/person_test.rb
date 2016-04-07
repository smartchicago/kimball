# == Schema Information
#
# Table name: people
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  last_name                        :string(255)
#  email_address                    :string(255)
#  address_1                        :string(255)
#  address_2                        :string(255)
#  city                             :string(255)
#  state                            :string(255)
#  postal_code                      :string(255)
#  geography_id                     :integer
#  primary_device_id                :integer
#  primary_device_description       :string(255)
#  secondary_device_id              :integer
#  secondary_device_description     :string(255)
#  primary_connection_id            :integer
#  primary_connection_description   :string(255)
#  phone_number                     :string(255)
#  participation_type               :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  signup_ip                        :string(255)
#  signup_at                        :datetime
#  voted                            :string(255)
#  called_311                       :string(255)
#  secondary_connection_id          :integer
#  secondary_connection_description :string(255)
#  verified                         :string(255)
#  preferred_contact_method         :string(255)
#  token                            :string(255)
#

require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  test 'should create new from wufoo params' do
    skip('to be fixed later: new validations are breaking these')
    new_person = Person.initialize_from_wufoo(wufoo_params)
    assert new_person.save
    assert_equal 'Jim', new_person.first_name
    assert_equal 'jim@example.com', new_person.email_address
    assert_equal 'Chicago', new_person.city
    assert_equal 'Either one', new_person.participation_type
    assert_not_nil new_person.signup_at
  end

  test 'should map wufoo device description to correct id' do
    skip('to be fixed later: new validations are breaking these')
    new_person = Person.initialize_from_wufoo(wufoo_params.update('Field39' => 'Smart phone'))
    assert new_person.save
    assert_equal 2, new_person.primary_device_id
  end

  test 'should map wufoo connection description to correct id' do
    skip('to be fixed later: new validations are breaking these')
    new_person = Person.initialize_from_wufoo(wufoo_params.update('Field41' => 'Magical Connection'))
    assert new_person.save
    assert_equal 2, new_person.primary_connection_id
  end
  test 'should have a comment associated' do
    assert_equal 1, people(:one).comments.size
    assert_equal comments(:one).content, people(:one).comments.first.content
  end

  test 'should know about events' do
    assert_equal 2, people(:one).events.count
    assert_equal 1, people(:two).events.count
  end

  test 'can add a tag to a person' do
    assert !people(:one).tags.detect { |tag| tag.name == 'foo bar baz' }

    people(:one).tags << Tag.new(name: 'foo bar baz', created_by: users(:admin).id)
    people(:one).tags.reload
    assert people(:one).tags.detect { |tag| tag.name == 'foo bar baz' }
  end

end
