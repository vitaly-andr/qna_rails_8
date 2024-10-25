require 'rails_helper'

RSpec.describe 'Google OAuth2', type: :request do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                         provider: 'google_oauth2',
                                                                         uid: '123456',
                                                                         info: {
                                                                           name: 'Test User',
                                                                           email: 'testuser@example.com',
                                                                           first_name: 'Test',
                                                                           last_name: 'User',
                                                                           image: 'http://example.com/test_user.jpg'
                                                                         },
                                                                         credentials: {
                                                                           token: 'mock_token',
                                                                           refresh_token: 'mock_refresh_token',
                                                                           expires_at: Time.now + 1.week
                                                                         },
                                                                         extra: {
                                                                           raw_info: {
                                                                             locale: 'en',
                                                                             gender: 'male'
                                                                           }
                                                                         }
                                                                       })
  end

  it 'authenticates the user via Google and redirects to the root path' do
    get '/users/auth/google_oauth2/callback'

    expect(response).to redirect_to(root_path)

    follow_redirect!

    expect(response.body).to include('Logged in as testuser@example.com')
  end
end
