require 'rails_helper'

feature 'User can view question and answers', %q(
  In order to get help from community
  As a user
  I want to be able to view a question and the answers to it
) do
  given!(:question) { create(:question, title: 'Test question', body: 'Question body') }
  given!(:answers) { create_list(:answer, 3, question: question) }

  scenario 'User views question and its answers' do
    visit question_path(question)

    expect(page).to have_content question.title
    expect(page).to have_content question.body

    answers.each do |answer|
      expect(page).to have_content answer.body
    end
  end
end
