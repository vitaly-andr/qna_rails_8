require 'rails_helper'

feature 'Author can edit their answer', %q(
  In order to fix mistakes
  As an authenticated user
  I want to be able to edit my answer
) do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, author: user) }

  scenario 'Author edits their answer, attaches files, and updates links', js: true do
    create(:link, name: 'Gist link', url: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a', linkable: answer)
    create(:link, name: 'GitHub', url: 'https://github.com', linkable: answer)
    answer.files.attach(io: File.open("#{Rails.root}/spec/fixtures/files/old_image.webp"), filename: 'old_image.webp', content_type: 'image/webp')

    sign_in(user)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      click_on 'Edit'

      fill_in 'Your Answer', with: 'Edited answer'

      attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]

      within "#link_#{answer.links.first.id}" do
        fill_in 'Link name', with: 'Updated Gist Link'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      click_on 'Add Link'
      within all('.nested-fields').last do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end

      click_on 'Update Answer'

      expect(page).to_not have_selector 'textarea'
      expect(page).to have_content 'Edited answer'

      expect(page).to have_link 'old_image.webp'
      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'

      expect(page).to have_link 'Updated Gist Link', href: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      expect(find('div[data-url="https://google.com"]')['data-url']).to eq 'https://google.com'
    end
  end

  scenario 'Author tries to edit their answer with invalid data' do
    sign_in(user)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      click_on 'Edit'

      fill_in 'Your Answer', with: ''

      click_on 'Update Answer'

      expect(page).to have_content "Body can't be blank"

      expect(find_field('Your Answer').value).to eq ''

    end
  end

  scenario 'Non-author cannot see the Edit link for someone else’s answer' do
    sign_in(other_user)
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to_not have_link 'Edit'
    end
  end

  scenario 'Unauthenticated user cannot see the Edit link' do
    visit question_path(question)

    within "turbo-frame##{dom_id(answer)}" do
      expect(page).to_not have_link 'Edit'
    end
  end
end