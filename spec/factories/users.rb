FactoryBot.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    email
    password { '12345678' }
    password_confirmation { '12345678' }
    confirmed_at { Time.now } # Чтобы обходить подтверждение почты
    name { FFaker::Name.name }
  end
end
