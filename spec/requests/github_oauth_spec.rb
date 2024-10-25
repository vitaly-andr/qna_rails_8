require 'rails_helper'

RSpec.describe 'GitHub OAuth2', type: :request do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
                                                                  provider: 'github',
                                                                  uid: '123456',
                                                                  info: {
                                                                    name: 'Test User',
                                                                    email: 'testuser@example.com'
                                                                  },
                                                                  credentials: {
                                                                    token: 'mock_token',
                                                                    refresh_token: 'mock_refresh_token',
                                                                    expires_at: Time.now + 1.week
                                                                  }
                                                                })

    allow(GithubApiService).to receive(:new).with('mock_token').and_return(double(fetch_user_emails: ['primary@example.com']))
  end

  it 'authenticates the user via GitHub, fetches emails via service, and redirects' do
    get '/users/auth/github/callback'

    expect(response).to redirect_to(root_path)

    follow_redirect!

    expect(response.body).to include('Logged in as primary@example.com')
  end
end
