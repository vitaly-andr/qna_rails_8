require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:question) { create(:question) }
  let(:answer) { create(:answer, question: question, author: user) }

  before { login(user) }


  describe 'POST #create' do
    context 'with valid attributes' do
      context 'Turbo request' do
        it 'saves a new answer in the database and renders Turbo Stream' do
          expect {
            post :create, params: { question_id: question.id, answer: attributes_for(:answer) }, format: :turbo_stream
          }.to change(Answer, :count).by(1)

          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
          expect(response).to render_template('answers/create')
        end
      end

      context 'HTML request' do
        it 'saves a new answer in the database and redirects to question page' do
          expect {
            post :create, params: { question_id: question.id, answer: attributes_for(:answer) }, format: :html
          }.to change(Answer, :count).by(1)

          expect(response).to redirect_to assigns(:question)
        end
      end
    end

    context 'with invalid attributes' do
      context 'Turbo request' do
        it 'does not save the answer and re-renders the form with Turbo Stream' do
          expect {
            post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid) }, format: :turbo_stream
          }.to_not change(Answer, :count)

          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
          expect(response).to render_template('answers/create_error')
        end
      end

      context 'HTML request' do
        it 'does not save the answer and re-renders the question page' do
          expect {
            post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid) }, format: :html
          }.to_not change(Answer, :count)

          expect(response).to render_template 'questions/show'
        end
      end
    end
  end

  describe 'POST #create as unauthenticated user' do
    before { sign_out(user) }

    it 'does not save the answer and redirects to login page' do
      expect {
        post :create, params: { question_id: question.id, answer: attributes_for(:answer) }
      }.to_not change(Answer, :count)

      expect(response).to redirect_to new_user_session_path
    end
  end

  describe 'GET #edit' do
    context 'When author tries to edit their answer' do
      before do
        get :edit, params: { id: answer.id, question_id: question.id }
      end

      it 'assigns the requested answer to @answer' do
        expect(assigns(:answer)).to eq answer
      end

      it 'renders the :edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'When non-author tries to edit the answer' do
      before { login(other_user) }

      it 'redirects to the question show view with alert' do
        get :edit, params: { id: answer.id, question_id: question.id }
        expect(response).to redirect_to(question_path(assigns(:question)))
        expect(flash[:alert]).to eq 'You can edit only your own answers.'
      end
    end

  end

  describe 'PATCH #update' do
    context 'When author tries to update their answer with valid attributes' do
      it 'updates the answer' do
        patch :update, params: { id: answer.id, question_id: question.id, answer: { body: 'Updated body' } }
        answer.reload
        expect(answer.body).to eq 'Updated body'
      end

      it 'redirects to the question show view' do
        patch :update, params: { id: answer.id, question_id: question.id, answer: { body: 'Updated body' } }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'When non-author tries to update the answer' do
      before { login(other_user) }

      it 'does not update the answer' do
        expect do
          patch :update, params: { id: answer.id, question_id: question.id, answer: { body: 'Updated body' } }
          answer.reload
        end.not_to change { answer.body }
      end

      it 'redirects to the question show view with alert' do
        patch :update, params: { id: answer.id, question_id: question.id, answer: { body: 'Updated body' } }
        expect(response).to redirect_to assigns(:question)
        expect(flash[:alert]).to eq 'You can update only your own answers.'
      end
    end

    context 'with invalid attributes' do
      it 'does not update the answer' do
        expect do
          patch :update, params: { id: answer.id, question_id: question.id, answer: attributes_for(:answer, :invalid) }
          answer.reload
        end.not_to change { answer.body }
      end

      it 're-renders the edit view' do
        patch :update, params: { id: answer.id, question_id: question.id, answer: attributes_for(:answer, :invalid) }
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'When author tries to delete their answer' do
      let!(:question) { create(:question, author: user) }

      let!(:answer) { create(:answer, question: question, author: user) }

      it 'deletes the answer' do
        expect { delete :destroy, params: { id: answer.id, question_id: question.id } }.to change(Answer, :count).by(-1)
      end

      it 'redirects to the question show view' do
        delete :destroy, params: { id: answer.id, question_id: question.id }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'When non-author tries to delete the answer' do
      before { login(other_user) }
      let!(:question) { create(:question, author: user) }

      let!(:answer) { create(:answer, question: question, author: user) }

      it 'does not delete the answer' do
        expect { delete :destroy, params: { id: answer.id, question_id: question.id } }.to_not change(Answer, :count)
      end

      it 'redirects to the question show view with alert' do
        delete :destroy, params: { id: answer.id, question_id: question.id }
        expect(response).to redirect_to assigns(:question)
        expect(flash[:alert]).to eq 'You can delete only your own answers.'
      end
    end
  end
end
