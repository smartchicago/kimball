require 'rails_helper'
require 'faker'
require 'support/poltergeist_js_hack_for_login'
require 'capybara/email/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

feature 'tag person'  do
  scenario 'add tag' do
    #probably need to add js: true to this

    # login_with_admin_user
    # person = FactoryGirl.create(:person)
    # tag_name = Faker::Company.buzzword
    # visit "/people/#{person.id}"

    # expect(page).to have_button('Add')

    # #fill_in_autocomplete '#tag-typeahead', tag_name
    # fill_in 'tagging[name]', with: tag_name
    # find_button('Add').trigger('click')

    # # gotta reload so that we don't cache tags
    # person.reload
    # found_tag = person.taggings.first ? person.taggings.first.name : false
    # expect(found_tag).to eq(tag_name)

    # # should have a deletable tag there.
    # expect(page).to have_selector('.delete-link')
  end

  scenario 'delete tag' do
    #probably need to add js: true to this

    # login_with_admin_user
    # person = FactoryGirl.create(:person, preferred_contact_method: 'EMAIL')
    # tag_name = Faker::Company.buzzword
    # visit "/people/#{person.id}"

    # expect(page).to have_button('Add')

    # fill_in 'tagging[name]', with: tag_name

    # find_button('Add').trigger('click')
    # expect(page).to have_selector('.delete-link')

    # expect(find(:css,'#tag-typeahead').value).to_not eq(tag_name)

    # find(:css,".delete-link").find("a").click
    # expect(page).to_not have_text(tag_name)
  end
end
