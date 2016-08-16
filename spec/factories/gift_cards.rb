FactoryGirl.define do
  factory :gift_card do
    last_four 1
    expiration_date '2016-06-03'
    person_id 1
    notes 'MyString'
    created_by 1
    reason 1
  end
end
