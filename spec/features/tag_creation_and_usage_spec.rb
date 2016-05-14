require 'rails_helper'
require 'faker'
require 'support/poltergeist_js_hack_for_login'
require 'capybara/email/rspec'

feature 'tag person'  do
  scenario 'add tag', js: :true  do
    person = FactoryGirl.create(:person)
    login_with_admin_user

    tag_name = Faker::Company.buzzword
    visit "/people/#{person.id}"
    expect(page).to have_button('Add')

    fill_in_autocomplete '#tag-typeahead', tag_name

    find_button('Add').trigger('click')
    sleep 1 # wait for our page to save
    # gotta reload so that we don't cache tags
    person.reload
    found_tag = person.taggings.first ? person.taggings.first.tag.name : false
    expect(found_tag).to eq(tag_name)

    visit "/people/#{person.id}"
    # should have a deletable tag there.
    expect(page.evaluate_script("$('a.delete-link').length")).to eq(1)
  end

  scenario 'delete tag', js: :true  do
    person = FactoryGirl.create(:person, preferred_contact_method: 'EMAIL')
    login_with_admin_user

    tag_name = Faker::Company.buzzword
    visit "/people/#{person.id}"

    expect(page).to have_button('Add')
    sleep 1
    fill_in_autocomplete '#tag-typeahead', tag_name
    sleep 1
    find_button('Add').trigger('click')
    sleep 1
    expect(page.evaluate_script("$('a.delete-link').length")).to eq(1)

    expect(find(:css, '#tag-typeahead').value).to_not eq(tag_name)
    page.execute_script("$('a.delete-link').click();")
    sleep 1
    expect(page).to_not have_text(tag_name)
  end
end
