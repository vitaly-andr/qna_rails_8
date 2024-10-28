require 'rails_helper'

feature 'User can view list of questions', %q(
  In order to find an interesting question
  As a user
  I want to be able to view a list of questions
) do
  given!(:questions) { create_list(:question, 3) }

  scenario 'User views list of questions' do
    visit questions_path

    questions.each do |question|
      expect(page).to have_content question.title
    end
  end
end
