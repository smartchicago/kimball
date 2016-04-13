FactoryGirl.define do
  factory :mailchimp_update do
    raw_content "MyText"
email "MyString"
update_type "MyString"
reason "MyString"
fired_at "2016-03-30 13:01:21"
  end

end
