require 'rails_helper'

feature 'User can register', %q(
  In order to ask questions and provide answers
  As an unauthenticated user
  I want to be able to register from the login page
) do
  background do
    visit new_user_session_path
    click_on 'Sign up'
  end

  scenario 'User registers with valid data' do
    fill_in 'Name', with: 'John Doe'
    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'Password', with: 'password', match: :first
    fill_in 'Password confirmation', with: 'password'

    click_on 'Sign up'

    expect(page).to have_content 'confirmation link has been sent '
  end

  scenario 'User registers with invalid data' do
    fill_in 'Email', with: ''
    fill_in 'Password', with: '', match: :first
    fill_in 'Password confirmation', with: ''

    click_on 'Sign up'

    expect(page).to have_content "can't be blank"
  end
end
