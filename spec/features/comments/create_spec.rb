require 'rails_helper'

feature 'User can add comments to question', %q{
  In order to clarify or discuss a question
  As an authenticated user
  I want to be able to add comments to a question
} do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'User adds a comment to a question', js: true do
    within("##{dom_id(question, :comments)}") do
      click_on 'Comment'
      fill_in 'Add a comment', with: 'This is a new comment'
      click_on 'Comment'

      expect(page).to have_content 'This is a new comment'
      expect(page).to have_content user.name
    end
  end

  scenario 'User tries to add an empty comment to a question', js: true do
    within("##{dom_id(question, :comments)}") do
      click_on 'Comment'
      click_on 'Comment'
    end
    expect(page).to have_content "Body can't be blank"
  end
end

