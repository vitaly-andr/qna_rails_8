require 'rails_helper'

RSpec.describe 'Questions API', type: :request do
  let!(:user) { create(:user) }
  let!(:application) { create(:application) }
  let!(:token) { create(:access_token, resource_owner_id: user.id, application: application) }
  let!(:questions) { create_list(:question, 3, author: user) }
  let!(:answers) { create_list(:answer, 2, question: questions.first, author: user) }

  describe 'GET /api/v1/questions' do
    it 'returns 200 status and a list of questions' do
      get '/api/v1/questions', headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['questions'].size).to eq(3)
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let(:question) { questions.first }

    it 'returns 200 status and the question details including comments, files, and links' do
      get "/api/v1/questions/#{question.id}", headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      question_data = json['question']
      expect(question_data['id']).to eq(question.id)
      expect(question_data).to have_key('comments')
      expect(question_data).to have_key('files')
      expect(question_data).to have_key('links')
    end
  end

  describe 'GET /api/v1/questions/:question_id/answers' do
    let(:question) { questions.first }

    it 'returns 200 status and a list of answers for the question' do
      get "/api/v1/questions/#{question.id}/answers", headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      answers_data = json['answers']
      expect(answers_data.size).to eq(2)
    end
  end

  describe 'POST /api/v1/questions/:question_id/answers' do
    let(:question) { questions.first }
    let(:valid_params) { { answer: { body: 'New Answer' } } }

    it 'creates a new answer for the question and returns 201 status' do
      expect {
        post "/api/v1/questions/#{question.id}/answers", params: valid_params, headers: { 'Authorization' => "Bearer #{token.token}" }
      }.to change(Answer, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let!(:answers) { create_list(:answer, 2, question: questions.first, author: user) }
    let(:answer) { answers.first }
    let(:update_params) { { answer: { body: 'Updated Answer' } } }

    it 'updates the answer and returns 200 status' do
      patch "/api/v1/answers/#{answer.id}", params: update_params, headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      answer_data = json['answer']
      expect(answer_data['body']).to eq('Updated Answer')
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let(:answer) { answers.first }

    it 'deletes the answer and returns 204 status' do
      expect {
        delete "/api/v1/answers/#{answer.id}", headers: { 'Authorization' => "Bearer #{token.token}" }
      }.to change(Answer, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /api/v1/questions' do
    let(:valid_params) { { question: { title: 'New Question', body: 'Question body' } } }

    it 'creates a new question and returns 201 status' do
      expect {
        post '/api/v1/questions', params: valid_params, headers: { 'Authorization' => "Bearer #{token.token}" }
      }.to change(Question, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:question) { questions.first }
    let(:update_params) { { question: { title: 'Updated Title' } } }

    it 'updates the question and returns 200 status' do
      patch "/api/v1/questions/#{question.id}", params: update_params, headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      question_data = json['question']
      expect(question_data['title']).to eq('Updated Title')
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:question) { questions.first }

    it 'deletes the question and returns 204 status' do
      expect {
        delete "/api/v1/questions/#{question.id}", headers: { 'Authorization' => "Bearer #{token.token}" }
      }.to change(Question, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end