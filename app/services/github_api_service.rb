class GithubApiService
  GITHUB_API_URL = 'https://api.github.com/user/emails'

  def initialize(token)
    @token = token
  end

  def fetch_user_emails
    response = RestClient.get(GITHUB_API_URL, headers)
    JSON.parse(response.body).map { |email| email['email'] }
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error "GitHub api Error: #{e.message}"
    []
  end

  private

  def headers
    { Authorization: "token #{@token}" }
  end
end
