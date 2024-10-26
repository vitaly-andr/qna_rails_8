require 'rails_helper'

feature 'Reward system', %q(
  In order to motivate users to give the best answers
  As an authenticated user
  I want to be able to create a question with a reward and assign the reward to the best answer
), js: true do
  given(:user) { create(:user) }
  given(:another_user) { create(:user) }
  given(:question_with_reward) { create(:question, author: user, reward: build(:reward)) }

  background do
    sign_in(user)
  end

  scenario 'User creates a question with a reward' do
    visit new_question_path

    fill_in 'Title', with: 'Question with reward'
    fill_in 'Body', with: 'Question body with reward'

    fill_in 'Название награды', with: 'Best Answer Reward'
    attach_file 'Изображение награды', "#{Rails.root}/spec/fixtures/files/reward_image.webp"

    click_on 'Save'

    expect(page).to have_content('Question was successfully created.')
    expect(page).to have_content('Question with reward')
    expect(page).to have_css("img[src*='reward_image.webp']")
  end

  scenario 'User assigns a reward to the best answer' do
    visit new_question_path

    fill_in 'Title', with: 'Question with reward for best answer'
    fill_in 'Body', with: 'Question body'

    fill_in 'Название награды', with: 'Best Answer Reward'
    attach_file 'Изображение награды', "#{Rails.root}/spec/fixtures/files/reward_image.webp"

    click_on 'Save'

    click_on 'Sign out'
    sign_in(another_user)

    visit question_path(Question.last)
    fill_in 'Your Answer', with: 'Answer body'
    click_on 'Submit Answer'
    answer = Answer.last

    expect(page).to have_content('Answer body')

    click_on 'Sign out'
    sign_in(user)

    visit question_path(Question.last)
    within "turbo-frame##{dom_id(answer)}" do
      click_button 'Mark as Best'
    end

    expect(page).to have_content('Answer body')

    click_on 'Sign out'
    sign_in(another_user)

    visit rewards_path
    expect(page).to have_content('Best Answer Reward')
    expect(page).to have_css("img[src*='reward_image.webp']")
    expect(page).to have_content('Question with reward for best answer')
  end
end
