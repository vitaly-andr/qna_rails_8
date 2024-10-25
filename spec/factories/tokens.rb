FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    resource_owner_id { create(:user).id }
    application { create(:application) }
    expires_in { 2.hours }
    scopes { 'read write' }
  end

  factory :application, class: 'Doorkeeper::Application' do
    name { 'Test Application' }
    redirect_uri { 'https://localhost/callback' }
  end
end