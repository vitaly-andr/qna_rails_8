require 'rails_helper'

feature 'User can search dynamically', %q{
  In order to find relevant information
  As a user
  I want to see search results as I type
} do

  given!(:question) { create(:question, title: 'How to integrate searchkick in Rails?') }
  given!(:answer)   { create(:answer, body: 'Searchkick is a full-text search engine') }
  given!(:comment)  { create(:comment, body: 'I love Searchkick') }
  given!(:user) { create(:user) }

  background do
    Question.reindex
    Answer.reindex
    Comment.reindex
    User.reindex

    Question.search_index.refresh
    Answer.search_index.refresh
    Comment.search_index.refresh
    User.search_index.refresh

    visit root_path
    click_link 'Search', target: '_top' # Clicking the search link to navigate to the search page
  end

  scenario 'User sees results as they type a valid query', js: true do
    fill_in 'Search...', with: 'searchkick'
    # Check that search results are displayed on the screen
    expect(page).to have_content 'How to integrate searchkick in Rails?'
    expect(page).to have_content 'Searchkick is a full-text search engine'
    expect(page).to have_content 'I love Searchkick'
  end

  scenario 'User sees "No results found" when removing query to less than 3 characters', js: true do
    fill_in 'Search...', with: 'searchkick'

    # Check that the results are initially displayed
    expect(page).to have_content 'How to integrate searchkick in Rails?'

    # Remove text to less than 3 characters

    fill_in 'Search...', with: 'se'
    # Check that the "No results found" message is displayed
    expect(page).to have_content 'No results found'
  end

  scenario 'User sees "No results found" for invalid query', js: true do

    fill_in 'Search...', with: 'Non-existing content'

    # Check that the "No results found" message is displayed
    expect(page).to have_content 'No results found'
  end
end
