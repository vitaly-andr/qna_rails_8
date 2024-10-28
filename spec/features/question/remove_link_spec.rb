require 'rails_helper'

feature 'Author can delete links from their question', "
  In order to remove irrelevant links
  As an author of the question
  I'd like to be able to delete links from my question
" do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given!(:link) { create(:link, linkable: question) }

  describe 'Authenticated user', js: true do
    scenario 'Author deletes link from their question on Question page' do
      sign_in(user)
      visit question_path(question)

      within "turbo-frame##{dom_id(question)}" do
        expect(find('div[data-url="https://example.com"]')['data-url']).to eq 'https://example.com'

        within "#link_#{link.id}" do
          click_on 'X'
        end
        expect { find('div[data-url="https://example.com"]') }.to raise_error(Capybara::ElementNotFound)
      end
      expect(page).to have_css('#flash-messages', text: 'Link was successfully removed.')

    end

    scenario 'Author deletes link from their question on Index page' do
      sign_in(user)
      visit questions_path

      within "turbo-frame##{dom_id(question)}" do
        expect(find('div[data-url="https://example.com"]')['data-url']).to eq 'https://example.com'

        within "#link_#{link.id}" do
          click_on 'X'
        end
        expect { find('div[data-url="https://example.com"]') }.to raise_error(Capybara::ElementNotFound)
      end
      expect(page).to have_css('#flash-messages', text: 'Link was successfully removed.')

    end

    scenario 'Another user tries to delete link from someone else\'s question' do
      sign_in(other_user)
      visit question_path(question)

      within "turbo-frame##{dom_id(question)}" do
        expect(find('div[data-url="https://example.com"]')['data-url']).to eq 'https://example.com'
        expect(page).to_not have_link 'X'
      end
    end
  end

  scenario 'Unauthenticated user cannot delete links' do
    visit question_path(question)

    within "turbo-frame##{dom_id(question)}" do
      expect(find('div[data-url="https://example.com"]')['data-url']).to eq 'https://example.com'
      expect(page).to_not have_link 'X'
    end
  end
end
