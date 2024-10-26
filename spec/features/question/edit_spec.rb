require 'rails_helper'

feature 'Author can edit their question', %q(
  In order to correct mistakes or add details
  As an authenticated user and author of the question
  I want to be able to edit my question inline and update links
), js: true do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given!(:question) { create(:question, author: user) }

  scenario 'Author edits their question from the index page, attaches files, and updates links' do
    create(:link, name: 'Gist link', url: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a', linkable: question)
    create(:link, name: 'GitHub', url: 'https://github.com', linkable: question)
    question.files.attach(io: File.open("#{Rails.root}/spec/fixtures/files/old_image.webp"), filename: 'old_image.webp', content_type: 'image/webp')

    sign_in(user)
    visit questions_path

    within "turbo-frame##{dom_id(question)}" do
      click_on 'Edit Question'

      fill_in 'Title', with: 'Edited Question Title'
      fill_in 'Body', with: 'Edited Question Body'

      attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]

      click_on 'Add Link'

      within "#link_#{question.links.first.id}" do
        fill_in 'Link name', with: 'Updated Gist Link'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      click_on 'Add Link'
      within all('.nested-fields').last do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end

      click_on 'Save'

      expect(page).to have_no_selector 'textarea'
      expect(page).to have_content 'Edited Question Title'
      expect(page).to have_content 'Edited Question Body'

      expect(page).to have_link 'old_image.webp'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'

      expect(page).to have_link 'Updated Gist Link', href: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      expect(find('div[data-url="https://google.com"]')['data-url']).to eq 'https://google.com'
    end
  end
  scenario 'Author attaches files to the question via file input click' do
    # Используем заранее прикрепленный файл reward_image.webp как старый файл
    question.files.attach(io: File.open("#{Rails.root}/spec/fixtures/files/old_image.webp"), filename: 'old_image.webp', content_type: 'image/webp')

    sign_in(user)
    visit questions_path

    within "turbo-frame##{dom_id(question)}" do
      click_on 'Edit Question'

      fill_in 'Title', with: 'Edited Question Title'
      fill_in 'Body', with: 'Edited Question Body'

      # Клик по полю для загрузки файлов
      # find('label[for="question_files"]').click

      # Используем attach_file для выбора файлов после клика
      attach_file 'question_files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"], visible: false

      click_on 'Save'

      # Проверяем, что файлы успешно прикреплены и отображены
      expect(page).to have_no_selector 'textarea'
      expect(page).to have_content 'Edited Question Title'
      expect(page).to have_content 'Edited Question Body'
      # Проверка наличия старого файла
      expect(page).to have_link 'old_image.webp'

      # Проверка наличия новых файлов
      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end
  end

  scenario 'Non-author tries to edit someone else’s question' do
    sign_in(other_user)
    visit questions_path

    within "turbo-frame##{dom_id(question)}" do
      expect(page).to_not have_link 'Edit Question'
    end
  end

  scenario 'Author tries to edit their question with invalid data' do
    sign_in(user)
    visit questions_path

    within "turbo-frame##{dom_id(question)}" do
      click_on 'Edit Question'

      fill_in 'Title', with: ''
      fill_in 'Body', with: ''

      click_on 'Save'

      expect(page).to have_content "Title can't be blank"
      expect(page).to have_content "Body can't be blank"

      expect(page).to have_selector 'textarea', text: ''
      expect(find_field('Title').value).to eq ''

    end
  end

  scenario 'Author edits their question from the question show page, attaches files, and updates links' do
    create(:link, name: 'Gist link', url: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a', linkable: question)
    create(:link, name: 'GitHub', url: 'https://github.com', linkable: question)

    sign_in(user)
    visit question_path(question)

    click_on 'Edit Question'
    within "turbo-frame##{dom_id(question)}" do

      fill_in 'Title', with: 'Edited Question Title on Show'
      fill_in 'Body', with: 'Edited Question Body on Show'

      attach_file 'question_files', [ "#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb" ]

      within '#question_form' do
        click_on 'Add Link'
      end
      within "#link_#{question.links.first.id}" do
        fill_in 'Link name', with: 'Updated Gist Link'
        fill_in 'Url', with: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      end

      within '#question_form' do
        click_on 'Add Link'
      end
      within all('.nested-fields').last do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: 'https://google.com'
      end

      click_on 'Save'

      expect(page).to_not have_selector '#question_form'
      expect(page).to have_content 'Edited Question Title on Show'
      expect(page).to have_content 'Edited Question Body on Show'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
      expect(page).to have_link 'Updated Gist Link', href: 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
      expect(find('div[data-url="https://google.com"]')['data-url']).to eq 'https://google.com'
    end
  end
end
