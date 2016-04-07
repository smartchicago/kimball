require 'faker'

FactoryGirl.define do
  factory :tag, class: Tag do
    name Faker::Internet.domain_word
  end

  factory :tagging, class: Tagging do
    taggable_type 'Person'

    before(:create) do |tagging|
      person = FactoryGirl.create(:person)
      tag    = FactoryGirl.create(:tag)
      tagging.tag_id = tag.id
      tagging.taggable_id = person.id
    end
  end
end
