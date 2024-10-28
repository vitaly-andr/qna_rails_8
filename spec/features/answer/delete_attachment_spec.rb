require 'rails_helper'

feature 'Author can delete attached files from their answer', %q(
  In order to remove unnecessary files
  As an authenticated user and author of the answer
  I want to be able to delete attached files
), js: true do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, author: user) }

  background do
    answer.files.attach(io: File.open("#{Rails.root}/spec/rails_helper.rb"), filename: 'rails_helper.rb')
    answer.files.attach(io: File.open("#{Rails.root}/spec/spec_helper.rb"), filename: 'spec_helper.rb')
  end

  scenario 'Author deletes one of the attached files', js: true do
    sign_in(user)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'

      # Удаляем один из файлов
      within "#file_#{answer.files.first.id}" do
        click_on 'X'
      end

      expect(page).to_not have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end
  end

  scenario 'Non-author cannot see delete links for files', js: true do
    sign_in(other_user)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to have_link 'rails_helper.rb'
      expect(page).to_not have_link 'X'
    end
  end

  scenario 'Unauthenticated user cannot see delete links for files', js: true do
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to have_link 'rails_helper.rb'
      expect(page).to_not have_link 'X'
    end
  end
end
