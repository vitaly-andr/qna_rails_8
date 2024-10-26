require 'rails_helper'

feature 'User can sign out', %q(
  In order to end the session
  As an authenticated user
  I want to be able to sign out
) do
  given(:user) { create(:user) }

  background do
    sign_in(user)
  end

  scenario 'Authenticated user tries to sign out' do
    visit root_path

    click_on 'Sign out'

    expect(page).to have_content 'Signed out successfully.'
    expect(page).to have_content 'Sign in'
  end
end
