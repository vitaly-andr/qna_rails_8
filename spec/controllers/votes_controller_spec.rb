require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:user) { create(:user) }
  let!(:question) { create(:question) }

  before { sign_in(user) }

  describe 'POST #create' do
    context 'when voting for a question' do
      it 'creates a vote' do
        expect {
          post :create, params: { votable_type: 'Question', votable_id: question.id, value: 1 }, format: :json
        }.to change(question.votes, :count).by(1)
      end


    end

    context 'when voting for their own question' do
      let!(:author) { create(:user) }
      let!(:own_question) { create(:question, author: author) }

      before { sign_in(author) }

      it 'does not allow to vote for own question' do
        post :create, params: { votable_type: 'Question', votable_id: own_question.id, value: 1 }, format: :json
        expect(response.status).to eq(403)
        expect(response.body).to include('You cannot vote for your own content')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes a vote' do
      question.vote_by(user, 1)
      expect {
        delete :destroy, params: { votable_type: 'Question', votable_id: question.id }, format: :json
      }.to change(question.votes, :count).by(-1)
    end
  end
end
