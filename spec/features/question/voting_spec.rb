require 'rails_helper'

feature 'Voting for a question', %q{
  In order to vote for a question I like
  As an authenticated user
  I'd like to be able to vote for or against a question on the question page
} do
  given(:user) { create(:user) }
  given(:author) { create(:user) }
  given!(:question) { create(:question, author: author) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'Authenticated user votes for a question', js: true do
    within "#question_#{question.id}.vote-area" do

      find('.vote__up').click

      expect(find('.vote__rating').text).to eq '1'
    end
  end

  scenario 'Authenticated user votes against a question', js: true do
    within "#question_#{question.id}.vote-area" do
      find('.vote__down').click

      expect(find('.vote__rating').text).to eq '-1'
    end
  end

  scenario 'Authenticated user cannot vote for their own question', js: true do
    click_on 'Sign out'
    sign_in(author)
    visit question_path(question)

    within "turbo-frame##{dom_id(question)}" do
      expect(page).not_to have_css '.vote__up'
      expect(page).not_to have_css '.vote__down'
    end
  end

  scenario 'Authenticated user can cancel their vote and vote again', js: true do
    within "#question_#{question.id}.vote-area" do
      find('.vote__up').click
      expect(find('.vote__rating').text).to eq '1'

      find('.vote__cancel').click
      expect(find('.vote__rating').text).to eq '0'

      find('.vote__down').click
      expect(find('.vote__rating').text).to eq '-1'
    end
  end

end

# Отдельная фича для голосования на странице индекса вопросов
feature 'Voting for a question on index page', %q{
  In order to vote for a question I like
  As an authenticated user
  I'd like to be able to vote for or against a question on the index page
} do
  given(:user) { create(:user) }
  given(:author) { create(:user) }
  given!(:question) { create(:question, author: author) }

  background do
    sign_in(user)
    visit questions_path
  end

  scenario 'Authenticated user votes for a question on index', js: true do
    within "#question_#{question.id}.vote-area" do
      find('.vote__up').click

      expect(find('.vote__rating').text).to eq '1'
    end
  end

  scenario 'Authenticated user votes against a question on index', js: true do
    within "#question_#{question.id}.vote-area" do
      find('.vote__down').click

      expect(find('.vote__rating').text).to eq '-1'
    end
  end

  scenario 'Authenticated user cannot vote for their own question on index', js: true do
    click_on 'Sign out'
    sign_in(author)
    visit questions_path

    within "turbo-frame##{dom_id(question)}" do
      expect(page).not_to have_css '.vote__up'
      expect(page).not_to have_css '.vote__down'
    end
  end

  scenario 'Authenticated user can cancel their vote and vote again on index', js: true do
    within "#question_#{question.id}.vote-area" do
      find('.vote__up').click
      expect(find('.vote__rating').text).to eq '1'

      find('.vote__cancel').click
      expect(find('.vote__rating').text).to eq '0'

      find('.vote__down').click
      expect(find('.vote__rating').text).to eq '-1'
    end
  end

end
