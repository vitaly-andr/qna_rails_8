require 'rails_helper'

feature 'User can add comments to answer', %q{
  In order to clarify or discuss an answer
  As an authenticated user
  I want to be able to add comments to an answer
} do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'User adds a comment to an answer', js: true do
    within("##{dom_id(answer, :comments)}") do
      click_on 'Comment'
      fill_in 'Add a comment', with: 'This is a new comment on the answer'
      click_on 'Comment'

      expect(page).to have_content 'This is a new comment on the answer'
      expect(page).to have_content user.name
    end
  end

  scenario 'User tries to add an empty comment to an answer', js: true do
    within("##{dom_id(answer, :comments)}") do
      click_on 'Comment'
      click_on 'Comment'
    end

    expect(page).to have_content "Body can't be blank"
  end
end
