require 'rails_helper'

RSpec.describe GithubApiService do
  let(:token) { 'mock_token' }
  let(:service) { described_class.new(token) }

  describe '#fetch_user_emails' do
    context 'when the request is successful' do
      before do
        stub_request(:get, 'https://api.github.com/user/emails')
          .with(headers: { 'Authorization' => "token #{token}" })
          .to_return(status: 200, body: '[{"email": "primary@example.com"}]', headers: {})
      end

      it 'returns the emails' do
        expect(service.fetch_user_emails).to eq(['primary@example.com'])
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:get, 'https://api.github.com/user/emails')
          .with(headers: { 'Authorization' => "token #{token}" })
          .to_return(status: 500)
      end

      it 'logs the error and returns an empty array' do
        expect(service.fetch_user_emails).to eq([])
      end
    end
  end
end
