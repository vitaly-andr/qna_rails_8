require 'rails_helper'
feature 'User can sign in', %q(
In order to sign in
As a unautheticated user
I want to sign in
) do
  given(:user) { create(:user) }
  background do
    visit root_path
    click_on 'Sign in'
  end

  scenario 'Registered user attempts to sign in' do
    sign_in(user)
    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'Unregistered user attempts to sign in' do
    fill_in 'Email', with: 'wrong@example.com'
    fill_in 'Password', with: 'password'
    click_on 'Log in'
    expect(page).to have_content 'Invalid Email or password.'
  end
end
