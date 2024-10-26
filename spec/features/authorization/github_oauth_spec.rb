require 'rails_helper'

RSpec.feature "GitHubOAuth", type: :feature do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
                                                                  provider: 'github',
                                                                  uid: '123456',
                                                                  info: {
                                                                    name: 'Test GitHub User',
                                                                    email: 'githubuser@example.com'
                                                                  },
                                                                  credentials: {
                                                                    token: 'mock_token',
                                                                    refresh_token: 'mock_refresh_token',
                                                                    expires_at: Time.now + 1.week
                                                                  }
                                                                })

    allow(GithubApiService).to receive(:new).with('mock_token').and_return(double(fetch_user_emails: ['githubuser@example.com']))
  end

  scenario 'User signs in via GitHub and is redirected' do
    visit new_user_session_path
    click_button 'Sign in with GitHub' # Assuming this is the button for GitHub sign-in

    expect(page).to have_current_path(root_path)

    expect(page).to have_content('Logged in as githubuser@example.com')
  end
end
