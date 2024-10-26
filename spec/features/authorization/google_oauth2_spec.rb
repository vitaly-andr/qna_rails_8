require 'rails_helper'

RSpec.feature "GoogleOAuth", type: :feature do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                         provider: 'google_oauth2',
                                                                         uid: '123456',
                                                                         info: {
                                                                           name: 'Test Google User',
                                                                           email: 'googleuser@example.com'
                                                                         },
                                                                         credentials: {
                                                                           token: 'mock_token',
                                                                           refresh_token: 'mock_refresh_token',
                                                                           expires_at: Time.now + 1.week
                                                                         }
                                                                       })
  end

  scenario 'User signs in via Google and is redirected' do
    visit new_user_session_path
    click_button 'Sign in with Google' # Assuming this is the button for Google sign-in

    expect(page).to have_current_path(root_path)

    expect(page).to have_content('Logged in as googleuser@example.com')
  end
end
