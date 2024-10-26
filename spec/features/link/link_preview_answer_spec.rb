require 'rails_helper'

feature 'User can see link previews', %q(
  In order to quickly preview link content
  As an authenticated or unauthenticated user
  I want to be able to see previews for Gist links and other links
), js: true do
  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'sees Gist link preview' do
      fill_in 'Your Answer', with: 'This is my answer with a Gist link'

      within all('.nested-fields').first do
        fill_in 'Link name', with: 'Gist link'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      click_on 'Submit Answer'
      last_answer = Answer.order(created_at: :desc).first

      within "turbo-frame##{dom_id(last_answer)}" do
        expect(page).to have_content 'This is my answer with a Gist link'

        # Проверка наличия контента из Gist в предварительном просмотре
        expect(page).to have_selector '.gist-preview', text: 'content of the Gist file'
      end
    end

    scenario 'sees preview for a non-Gist link using Microlink.js' do
      fill_in 'Your Answer', with: 'This is my answer with a regular link'

      within all('.nested-fields').first do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end

      click_on 'Submit Answer'
      last_answer = Answer.order(created_at: :desc).first

      within "turbo-frame##{dom_id(last_answer)}" do
        expect(page).to have_selector "img[src='https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png']"
      end
    end
  end

  describe 'Unauthenticated user' do
    scenario 'sees Gist content in an existing answer' do
      answer_with_gist = create(:answer, question: question)
      create(:link, name: 'Gist link', url: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a', linkable: answer_with_gist)

      visit question_path(question)

      within "#answer-#{answer_with_gist.id} .gist-preview" do
        expect(page).to have_content 'content of the Gist file'
      end
    end

    scenario 'sees regular link preview in an existing answer' do
      answer_with_link = create(:answer, question: question)
      create(:link, name: 'Google', url: 'https://google.com', linkable: answer_with_link)

      visit question_path(question)

      last_answer = Answer.order(created_at: :desc).first

      within "turbo-frame##{dom_id(last_answer)}" do
        expect(page).to have_selector "img[src='https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png']"
      end
    end
  end
end
