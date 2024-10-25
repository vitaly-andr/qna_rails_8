require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let(:answer) { create(:answer, question: question) }


  describe 'PATCH #mark_best_answer' do
    context 'when user is the author of the question' do
      before { sign_in user }

      it 'sets the best answer for the question' do
        puts ""
        patch :mark_best_answer, params: { id: question.id, answer_id: answer.id }
        question.reload
        expect(question.best_answer_id).to eq(answer.id)
      end

      it 'redirects to the question page with a success message' do
        patch :mark_best_answer, params: { id: question.id, answer_id: answer.id }
        expect(response).to redirect_to assigns(:question)
        expect(flash[:notice]).to eq 'Best answer selected.'
      end
    end

    context 'when user is not the author of the question' do
      before { sign_in other_user }

      it 'does not set the best answer' do
        patch :mark_best_answer, params: { id: question.id, answer_id: answer.id }
        expect(question.reload.best_answer).to be_nil
      end

      it 'redirects to the question page with alert' do
        patch :mark_best_answer, params: { id: question.id, answer_id: answer.id }
        expect(response).to redirect_to(question_path(assigns(:question)))
        expect(flash[:alert]).to eq 'You are not authorized to select the best answer.'
      end
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { id: question }
    end
    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end
    it 'renders the :show template' do
      expect(response).to render_template :show
    end
  end
  describe 'GET #new' do
    before { login(user) }

    before do
      get :new
    end
    it 'assigns a new question to @question' do
      expect(assigns(:question)).to be_a_new Question
      expect(assigns(:question).links.first).to be_a_new(Link)
    end
    it 'renders the :new template' do
      expect(response).to render_template :new
    end
  end
  describe 'GET #edit' do
    before { login(user) }

    before do
      get :edit, params: { id: question }
    end
    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end
    it 'renders the :edit template' do
      expect(response).to render_template :edit
    end
  end
  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new question in the database' do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(Question, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        expect { post :create, params: { question: attributes_for(:question, :invalid) } }.to_not change(Question, :count)
      end

      it 're-renders new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end
  describe 'PATCH #update' do
    before { login(user) }

    context 'with valid attributes' do
      it 'assigns the requested question to @question' do
        patch :update, params: { id: question, question: attributes_for(:question) }
        expect(assigns(:question)).to eq question
      end
      it 'changes @question' do
        patch :update, params: { id: question, question: { title: 'new title', body: 'new body' } }
        question.reload

        expect(question.title).to eq 'new title'
        expect(question.body).to eq 'new body'
      end
      it 'redirects to show view' do
        patch :update, params: { id: question, question: attributes_for(:question) }
        expect(response).to redirect_to assigns(:question)
      end
    end
    context 'with invalid attributes' do
      before do
        patch :update, params: { id: question.id, question: attributes_for(:question, :invalid) }
      end
      it 'does not change question' do
        question.reload

        expect(question.title).to eq question.title_was
        expect(question.body).to eq question.body_was
      end

      it 're-renders edit view' do
      expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'When author tries to delete their question' do
      before { login(user) }
      let!(:question) { create(:question, author: user) }
      it 'deletes the question' do
        expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
      end

      it 'redirects to questions index' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to questions_path
      end
    end

    context 'When non-author tries to delete the question' do
      before { login(other_user) }
      let!(:question) { create(:question, author: user) }

      it 'does not delete the question' do
        expect { delete :destroy, params: { id: question } }.to_not change(Question, :count)
      end

      it 'redirects to questions index with alert' do
        delete :destroy, params: { id: question }
        expect(response).to redirect_to(root_path)

        expect(flash[:alert]).to eq 'You can delete only your own questions.'
      end
    end
  end
end
