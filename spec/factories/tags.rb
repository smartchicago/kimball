# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_by     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  taggings_count :integer          default(0), not null
#

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
