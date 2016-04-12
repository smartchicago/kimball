module Helpers
  def login_with_admin_user
    user = FactoryGirl.create(:user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  def fill_in_autocomplete(selector, value)
    find(selector).native.send_keys(*value.chars)
  end

  def choose_autocomplete(text)
    find('.tt-selectable').has_content?(text)
    find(".tt-selectable:contains(\"#{text}\").a").click
  end

  def wait_for_ajax
    counter = 0
    while page.execute_script('return $.active').to_i > 0
      counter += 1
      sleep(0.1)
      raise 'AJAX request took longer than 5 seconds.' if counter >= 50
    end
  end

end
