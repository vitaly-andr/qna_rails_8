require 'rails_helper'

RSpec.describe 'VKontakte OAuth2', type: :request do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:vkontakte] = OmniAuth::AuthHash.new({
                                                                     provider: 'vkontakte',
                                                                     uid: '123456',
                                                                     info: {
                                                                       name: 'Test User',
                                                                       email: nil
                                                                     },
                                                                     credentials: {
                                                                       token: 'mock_token',
                                                                       refresh_token: 'mock_refresh_token',
                                                                       expires_at: Time.now + 1.week
                                                                     }
                                                                   })
  end

  it 'authenticates the user via VKontakte, generates a temporary email, and redirects to edit profile page' do
    # Step 1: Simulate user clicking VKontakte sign-in button and being redirected to callback
    get '/users/auth/vkontakte/callback'

    # Step 2: Expect to be redirected to the edit profile page
    expect(response).to redirect_to(edit_user_registration_path)

    follow_redirect!

    # Step 3: Check that the user is prompted to update and confirm their email
    expect(response.body).to include('Please update and confirm your email and create new password')

    # Step 4: Expect the temporary email to be generated correctly
    expected_email = '123456@vkontakte.com'
    expect(response.body).to include(expected_email)

  end

  it 'redirects to registration page if user is not persisted' do
    allow(User).to receive(:from_omniauth).and_return(User.new)

    get '/users/auth/vkontakte/callback'

    expect(response).to redirect_to(new_user_registration_url)
    follow_redirect!
    expect(response.body).to include('Authentication failed.')
  end
end
