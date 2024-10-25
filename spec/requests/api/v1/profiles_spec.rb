require 'rails_helper'

RSpec.describe 'Profiles API', type: :request do
  let!(:user) { create(:user) }
  let!(:application) { create(:application) }
  let!(:token) { create(:access_token, resource_owner_id: user.id, application: application) }

  describe 'GET /api/v1/profiles/me' do
    it 'returns 200 status and the profile of the current user' do
      get '/api/v1/profiles/me', headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['user']['id']).to eq(user.id)
    end
  end

  describe 'GET /api/v1/profiles' do
    let!(:other_users) { create_list(:user, 3) }

    it 'returns 200 status and a list of other user profiles' do
      get '/api/v1/profiles', headers: { 'Authorization' => "Bearer #{token.token}" }

      expect(response).to have_http_status(:success)
      parsed_response = JSON.parse(response.body)['users']
      expect(parsed_response.size).to eq(3)
      expect(parsed_response.map { |u| u['id'] }).to match_array(other_users.map(&:id))
    end
  end
end