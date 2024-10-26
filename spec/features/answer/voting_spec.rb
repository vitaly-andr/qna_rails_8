require 'rails_helper'

feature 'Voting for an answer', %q{
  In order to vote for an answer I like
  As an authenticated user
  I'd like to be able to vote for or against an answer on the question page
} do
  given(:user) { create(:user) }
  given(:author) { create(:user) }
  given!(:question) { create(:question, author: author) }
  given!(:answer) { create(:answer, question: question, author: author) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'Authenticated user votes for an answer', js: true do
    within "##{dom_id(answer)} .vote-area" do
      find('.vote__up').click

      expect(find('.vote__rating').text).to eq '1'
    end
  end

  scenario 'Authenticated user votes against an answer', js: true do
    within "##{dom_id(answer)} .vote-area" do
      find('.vote__down').click

      expect(find('.vote__rating').text).to eq '-1'
    end
  end

  scenario 'Authenticated user cannot vote for their own answer', js: true do
    click_on 'Sign out'
    sign_in(author)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).not_to have_css '.vote__up'
      expect(page).not_to have_css '.vote__down'
    end
  end

  scenario 'Authenticated user can cancel their vote and vote again for an answer', js: true do
    within "##{dom_id(answer)} .vote-area" do
      find('.vote__up').click
      expect(find('.vote__rating').text).to eq '1'

      find('.vote__cancel').click
      expect(find('.vote__rating').text).to eq '0'

      find('.vote__down').click
      expect(find('.vote__rating').text).to eq '-1'
    end
  end

end
