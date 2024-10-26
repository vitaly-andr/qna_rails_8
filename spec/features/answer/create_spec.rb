require 'rails_helper'

feature 'User can write an answer to a question', %q(
  In order to help other users
  As an authenticated user
  I want to be able to write an answer to a question directly on its page
), js: true do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given!(:existing_answer) { create(:answer, question: question, body: 'Existing answer') }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    context 'with full page reload' do
      scenario 'writes an answer' do
        last_answer = Answer.order(created_at: :desc).first

        within "turbo-frame##{dom_id(last_answer)}" do
          expect(page).to have_content 'Existing answer'
        end

        fill_in 'Your Answer', with: 'This is my new answer'
        click_on 'Submit Answer'

        last_answer = Answer.order(created_at: :desc).first

        within "##{dom_id(last_answer)}" do
          expect(page).to have_content 'This is my new answer'
        end
      end

      scenario 'tries to submit an empty answer' do
        click_on 'Submit Answer'

        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario 'writes an answer with attached files' do
      fill_in 'Your Answer', with: 'This is my answer with files'

      attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Submit Answer'
      last_answer = Answer.order(created_at: :desc).first
      within "##{dom_id(last_answer)}" do
        expect(page).to have_content 'This is my answer with files'
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end

    scenario 'writes an answer with multiple links and removes one before submitting' do
      fill_in 'Your Answer', with: 'This is my answer with links'

      within '.nested-fields' do
        fill_in 'Link name', with: 'My Gist'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      click_on 'Add Link'
      within all('.nested-fields').last do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end

      within all('.nested-fields').first do
        click_on 'Remove'
      end

      click_on 'Submit Answer'

      last_answer = Answer.order(created_at: :desc).first

      within "##{dom_id(last_answer)}" do
        expect(page).to have_content 'This is my answer with links'
        expect(page).to_not have_link 'My Gist', href: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
        expect(find('div[data-url="https://google.com"]')['data-url']).to eq 'https://google.com'
      end
    end


    context 'with Turbo Frame' do
      scenario 'writes an answer' do
        last_answer = Answer.order(created_at: :desc).first
        within "turbo-frame##{dom_id(last_answer)}" do
          expect(page).to have_content 'Existing answer'
        end

        fill_in 'Your Answer', with: 'This is my new answer'
        click_on 'Submit Answer'

        last_answer = Answer.order(created_at: :desc).first

        within "##{dom_id(last_answer)}" do
          expect(page).to have_content 'This is my new answer'
        end
        # expect(page).to have_selector 'textarea'
        expect(find_field('Your Answer').value).to be_empty
      end

      scenario 'writes an answer with attached files' do
        fill_in 'Your Answer', with: 'This is my answer with files'

        attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Submit Answer'

        last_answer = Answer.order(created_at: :desc).first

        within "##{dom_id(last_answer)}" do
          expect(page).to have_content 'This is my answer with files'
          expect(page).to have_link 'rails_helper.rb'
          expect(page).to have_link 'spec_helper.rb'
        end
        expect(find_field('Your Answer').value).to be_empty
      end

      scenario 'tries to submit an empty answer' do
        click_on 'Submit Answer'
        within '.answer-errors' do
          expect(page).to have_content "Body can't be blank"
        end
      end

      scenario 'tries to submit an answer with invalid link ' do

        within '.nested-fields' do
          fill_in 'Link name', with: 'My Gist'
          fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
        end

        click_on 'Add Link'
        within all('.nested-fields').first do
          fill_in 'Link name', with: 'Invalid Link'
          fill_in 'Url', with: 'invalid-url'
        end

        click_on 'Submit Answer'
        within '.answer-errors' do
          expect(page).to have_content "Body can't be blank"
        end
      end
    end
  end

  scenario 'Unauthenticated user tries to write an answer' do
    visit question_path(question)

    expect(page).to_not have_selector 'textarea'
    expect(page).to have_content 'You need to sign in or sign up before creating answers.'
  end
end
