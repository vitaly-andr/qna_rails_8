require 'rails_helper'

feature 'User can create question', %q(
  In order to get help from the community
  As an authenticated user
  I want to be able to create questions with links, attachments, and without errors
), js: true do
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'
    end

    scenario 'creates question' do
      fill_in 'Title', with: 'Title text'
      fill_in 'Body', with: 'text text text'
      click_on 'Save'
      expect(page).to have_content('Question was successfully created.')
      expect(page).to have_content('Title text')
      expect(page).to have_content('text text text')
    end

    scenario 'creates question with attached files' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'text text text'

      attach_file 'File', [ "#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb" ]
      click_on 'Save'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end

    scenario 'creates question with multiple links and removes one before submitting' do
      fill_in 'Title', with: 'Test question with multiple links'
      fill_in 'Body', with: 'text text text'

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

      click_on 'Save'

      expect(page).to have_content('Question was successfully created.')
      expect(page).to_not have_link 'My Gist', href: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      expect(find('div[data-url="https://google.com"]')['data-url']).to eq 'https://google.com'
    end

    scenario 'creates question with attached files and multiple links' do
      fill_in 'Title', with: 'Test question with files and links'
      fill_in 'Body', with: 'text text text'

      within '.nested-fields' do
        fill_in 'Link name', with: 'My Gist'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      click_on 'Add Link'
      within all('.nested-fields').last do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end

      attach_file 'File', [ "#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb" ]

      click_on 'Save'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
      expect(page).to have_link 'My Gist', href: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      expect(find('div[data-url="https://google.com"]')['data-url']).to eq 'https://google.com'
    end

    scenario 'tries to create question with errors' do
      click_on 'Save'
      expect(page).to have_content("Title can't be blank")
    end

    scenario 'tries to create question with invalid link' do
      fill_in 'Title', with: 'Test question with invalid link'
      fill_in 'Body', with: 'text text text'

      within '.nested-fields' do
        fill_in 'Link name', with: 'My Gist'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      click_on 'Add Link'
      within all('.nested-fields').first do
        fill_in 'Link name', with: 'Invalid Link'
        fill_in 'Url', with: 'invalid-url'
      end

      click_on 'Save'

      expect(page).to have_content('is not a valid URL')
    end
  end

  describe 'Non-authenticated user' do
    scenario 'tries to create question' do
      visit new_question_path
      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end
end
