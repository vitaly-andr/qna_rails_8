require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe 'GET #index' do
    context 'with valid query' do
      let(:query) { 'searchkick' }

      before do
        allow(Question).to receive(:search).and_return([create(:question, title: 'How to integrate searchkick in Rails?')])
        allow(Answer).to receive(:search).and_return([create(:answer, body: 'searchkick')])
        allow(Comment).to receive(:search).and_return([])
        allow(User).to receive(:search).and_return([])
      end

      it 'assigns @results for questions' do
        get :index, params: { query: query, model: 'questions' }
        expect(assigns(:results)).to all(be_a(Question))
      end

      it 'assigns @results for answers' do
        get :index, params: { query: query, model: 'answers' }
        expect(assigns(:results)).to all(be_a(Answer))
      end

      it 'assigns @results for comments' do
        get :index, params: { query: query, model: 'comments' }
        expect(assigns(:results)).to eq([])
      end

      it 'assigns @results for users' do
        get :index, params: { query: query, model: 'users' }
        expect(assigns(:results)).to eq([])
      end

      it 'assigns combined @results for all models when no model is specified' do
        get :index, params: { query: query }
        expect(assigns(:results)).to include(be_a(Question), be_a(Answer))
      end

      it 'renders the index template for HTML format' do
        get :index, params: { query: query }, format: :html
        expect(response).to render_template(:index)
      end

      it 'returns correct JSON for JSON format' do
        get :index, params: { query: query }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')

        # Проверяем, что "search_results" является массивом
        expect(json_response["search_results"]).to be_an(Array)

        # Дополнительно можно проверить, что в ответе присутствуют ожидаемые объекты
        expect(json_response["search_results"].first['title']).to eq('How to integrate searchkick in Rails?')
        expect(json_response["search_results"].second['body']).to eq('searchkick')
      end
    end

    context 'with invalid query' do

      it 'renders the index template for HTML format' do
        get :index, params: { query: '' }, format: :html
        expect(response).to render_template(:index)
      end

      it 'returns empty JSON array for empty query' do
        get :index, params: { query: '' }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(json_response["search_results"]).to eq([])
      end

      it 'does not assign @results if query is nil' do
        get :index, params: { query: nil }, format: :json
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(json_response["search_results"]).to eq([])
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
