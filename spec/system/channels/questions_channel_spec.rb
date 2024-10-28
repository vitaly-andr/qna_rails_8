require 'rails_helper'

RSpec.describe 'Turbo Stream with WebSocket', type: :system do
  let(:user) { create(:user) }
  let!(:question) { create(:question, title: 'Initial Question') }

  before do
    sign_in(user)
  end

  it 'create and update questions Turbo Stream' do
    visit live_feed_index_path

    expect(page).to have_text('Initial Question')

    new_question = create(:question, title: 'New Question')
    expect(page).to have_text('New Question')

    new_question.update(title: 'Updated New Question')
    expect(page).to have_text('Updated New Question')

    new_question.destroy
    expect(page).not_to have_text('Updated New Question')
  end
end

RSpec.describe 'Turbo Stream for Answers', type: :system do
  let(:user) { create(:user) }
  let!(:question) { create(:question, title: 'Initial Question') }
  let!(:answer) { create(:answer, question: question, body: 'Initial Answer') }

  before do
    sign_in(user)
  end

  it 'creates and updates answers via Turbo Stream' do
    visit live_feed_index_path

    expect(page).to have_text('Initial Answer')

    new_answer = create(:answer, question: question, body: 'New Answer')
    expect(page).to have_text('New Answer')

    new_answer.update(body: 'Updated New Answer')
    expect(page).to have_text('Updated New Answer')

    new_answer.destroy
    expect(page).not_to have_text('Updated New Answer')
  end
end

require 'rails_helper'

RSpec.describe 'Turbo Stream for Comments', type: :system do
  let(:user) { create(:user) }
  let!(:question) { create(:question, title: 'Initial Question') }
  let!(:answer) { create(:answer, question: question, body: 'Initial Answer') }

  before do
    sign_in(user)
  end

  it 'creates comments for question via Turbo Stream' do
    visit live_feed_index_path

    within "##{dom_id(question, :comments)}" do
      expect(page).to have_text('No comments yet')
    end

    new_comment = create(:comment, commentable: question, body: 'New Comment')

    within "##{dom_id(question, :comments)}" do
      expect(page).to have_text('New Comment')
      expect(page).not_to have_text('No comments yet')
    end
  end

  it 'creates comments for answer via Turbo Stream' do
    visit live_feed_index_path

    within "##{dom_id(answer, :comments)}" do
      expect(page).to have_text('No comments yet')
    end

    new_comment = create(:comment, commentable: answer, body: 'New Comment for Answer')

    within "##{dom_id(answer, :comments)}" do
      expect(page).to have_text('New Comment for Answer')
      expect(page).not_to have_text('No comments yet')
    end
  end
end