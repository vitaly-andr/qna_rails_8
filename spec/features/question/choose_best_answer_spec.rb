require 'rails_helper'

RSpec.feature "Choose Best Answer", type: :feature do
  let!(:question_author) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:question) { create(:question, author: question_author) }
  let!(:answers) { create_list(:answer, 3, question: question) }

  before do
    sign_in question_author
    visit question_path(question)
  end

  scenario 'Author can choose the second answer as the best', js: true do
    second_answer = answers.second

    within "turbo-frame##{dom_id(second_answer)}" do
      click_button 'Mark as Best'
    end

    expect(page).to have_css('.best-answer', text: second_answer.body)
    expect(page).to have_button('Unmark Best')
    expect(page).to_not have_button('Mark as Best', count: 1)

    within "turbo-frame##{dom_id(second_answer)}" do
      click_button 'Unmark Best'
    end

    expect(page).to_not have_css('.best-answer', text: second_answer.body)
    expect(page).to have_button('Mark as Best')
  end

  scenario 'Other users cannot choose the best answer' do
    click_link 'Sign out'
    sign_in other_user
    visit question_path(question)

    expect(page).not_to have_button('Mark as Best')
  end
end