require 'rails_helper'
require 'nokogiri'

RSpec.describe 'OmniAuth Error Handling', type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  shared_examples 'handles authentication error' do |provider, provider_name|
    it "can handle authentication error for #{provider}" do
      OmniAuth.config.mock_auth[provider] = :invalid_credentials

      get "/users/auth/#{provider}/callback"

      expect(response).to redirect_to(new_user_session_url)
      follow_redirect!

      parsed_html = Nokogiri::HTML(response.body)
      flash_message = parsed_html.css('turbo-frame#flash-messages .alert').text.strip

      expect(flash_message).to eq("Could not authenticate you from #{provider_name} because \"Invalid credentials\".")
    end
  end

  include_examples 'handles authentication error', :github, 'GitHub'
  include_examples 'handles authentication error', :google_oauth2, 'GoogleOauth2'
  include_examples 'handles authentication error', :vkontakte, 'Vkontakte'
end
