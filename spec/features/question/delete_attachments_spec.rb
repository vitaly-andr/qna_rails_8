require 'rails_helper'

feature 'Author can delete attached files from their question', %q(
  In order to remove unnecessary files
  As an authenticated user and author of the question
  I want to be able to delete attached files
), js: true do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given!(:question) { create(:question, author: user) }

  background do
    question.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'rails_helper.rb')
    question.files.attach(io: File.open("#{Rails.root}/spec/spec_helper.rb"), filename: 'spec_helper.rb')
  end

  feature 'Author deletes attached files from the question show page', js: true do
    scenario 'Author deletes one of the attached files' do
      sign_in(user)
      visit question_path(question)

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'

      within "#file_#{question.files.first.id}" do
        click_on 'X'
      end

      expect(page).to_not have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end

    scenario 'Non-author cannot see delete links for files' do
      sign_in(other_user)
      visit question_path(question)

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to_not have_link 'X'
    end

    scenario 'Unauthenticated user cannot see delete links for files' do
      visit question_path(question)

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to_not have_link 'X'
    end
  end

  feature 'Author deletes attached files from the index page', js: true do
    scenario 'Author deletes one of the attached files from the index page' do
      sign_in(user)
      visit questions_path

      within "turbo-frame##{dom_id(question)}" do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'

        within "#file_#{question.files.first.id}" do
          click_on 'X'
        end

        expect(page).to_not have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end

    scenario 'Non-author cannot see delete links for files on the index page' do
      sign_in(other_user)
      visit questions_path

      within "turbo-frame##{dom_id(question)}" do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to_not have_link 'X'
      end
    end

    scenario 'Unauthenticated user cannot see delete links for files on the index page' do
      visit questions_path

      within "turbo-frame##{dom_id(question)}" do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to_not have_link 'X'
      end
    end
  end
end
