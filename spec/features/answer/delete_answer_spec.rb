require 'rails_helper'

feature 'Author can delete their answer', %q(
  In order to remove incorrect answer
  As an authenticated user
  I want to be able to delete my answer
), js: true do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, author: user) }
  given!(:other_answer) { create(:answer, question: question, author: other_user) }

  scenario 'Author tries to delete their answer' do
    sign_in(user)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to have_link 'Delete Answer'
      click_on 'Delete Answer'
    end

    expect(page).to have_content 'Your answer was successfully deleted.'
    expect(page).to_not have_content answer.body
  end

  scenario 'Non-author tries to delete someone else’s answer' do
    sign_in(other_user)
    visit question_path(question)


    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to_not have_link 'Delete Answer'
    end
  end
end
