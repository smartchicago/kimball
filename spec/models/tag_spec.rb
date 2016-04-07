require 'rails_helper'

describe Tag do
  subject { FactoryGirl.build(:tag) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  it 'counter_cache updates' do
    expect(subject).to be_valid
    expect(subject.taggings_count).to eq(0)

    person = FactoryGirl.create(:person)
    user   = FactoryGirl.create(:user)

    @tag = Tag.find_or_initialize_by(name: subject.name)
    @tag.created_by ||= user.id
    @tagging = Tagging.new(taggable_type: person.class.to_s,
                            taggable_id: person.id,
                            tag: subject)

    @tagging.with_user(user).save

    expect(subject.taggings_count).to eq(1)

    @tagging.destroy
    subject.reload
    expect(subject.taggings_count).to eq(0)
  end
end
